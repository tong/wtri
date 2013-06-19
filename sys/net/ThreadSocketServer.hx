package sys.net;

import haxe.io.Bytes;
import sys.net.Socket;
#if cpp
import cpp.vm.Thread;
import cpp.vm.Lock;
import cpp.net.Poll;
#elseif neko
import neko.vm.Thread;
import neko.vm.Lock;
import neko.net.Poll;
#end

private typedef ThreadInfos = {
	var id : Int;
	var t : Thread;
	var p : Poll;
	var socks : Array<Socket>;
}

private typedef ClientInfos<Client> = {
	var client : Client;
	var sock : Socket;
	var thread : ThreadInfos;
	var buf : Bytes;
	var bufpos : Int;
}

class ThreadSocketServer<Client,Message> {

	public var listen : Int;
	public var nthreads : Int;
	public var connectLag : Float;
	public var errorOutput : haxe.io.Output;
	public var initialBufferSize : Int;
	public var maxBufferSize : Int;
	public var messageHeaderSize : Int;
	public var updateTime : Float;
	public var maxSockPerThread : Int;
	//public var active : Bool;

	var threads : Array<ThreadInfos>;
	var sock : Socket;
	var worker : Thread;
	var timer : Thread;

	public function new() {
		threads = new Array();
		nthreads = if( Sys.systemName() == "Windows" ) 150 else 10;
		messageHeaderSize = 1;
		listen = 10;
		connectLag = 0.5;
		errorOutput = Sys.stderr();
		initialBufferSize = (1 << 10);
		maxBufferSize = (1 << 16);
		maxSockPerThread = 64;
		updateTime = 1;
		//active = false;
	}

	function runThread(t) {
		while( true ) {
			try {
				loopThread(t);
			} catch( e : Dynamic ) {
				logError(e);
			}
		}
	}

	function readClientData( c : ClientInfos<Client> ) {
		var available = c.buf.length - c.bufpos;
		if( available == 0 ) {
			var newsize = c.buf.length * 2;
			if( newsize > maxBufferSize ) {
				newsize = maxBufferSize;
				if( c.buf.length == maxBufferSize )
					throw "Max buffer size reached";
			}
			var newbuf = haxe.io.Bytes.alloc(newsize);
			newbuf.blit(0,c.buf,0,c.bufpos);
			c.buf = newbuf;
			available = newsize - c.bufpos;
		}
		var bytes = c.sock.input.readBytes(c.buf,c.bufpos,available);
		var pos = 0;
		var len = c.bufpos + bytes;
		while( len >= messageHeaderSize ) {
			var m = readClientMessage(c.client,c.buf,pos,len);
			if( m == null )
				break;
			pos += m.bytes;
			len -= m.bytes;
			work(clientMessage.bind(c.client,m.msg));
		}
		if( pos > 0 )
			c.buf.blit(0,c.buf,pos,len);
		c.bufpos = len;
	}

	function loopThread( t : ThreadInfos ) {
		if( t.socks.length > 0 )
			for( s in t.p.poll( t.socks, connectLag ) ) {
				var infos : ClientInfos<Client> = s.custom;
				try {
					readClientData(infos);
				} catch( e : Dynamic ) {
					t.socks.remove(s);
					if( !Std.is(e,haxe.io.Eof) && !Std.is(e,haxe.io.Error) )
						logError(e);
					work(doClientDisconnected.bind(s,infos.client));
				}
			}
		while( true ) {
			var m : { s : Socket, cnx : Bool } = Thread.readMessage(t.socks.length == 0);
			if( m == null )
				break;
			if( m.cnx )
				t.socks.push(m.s);
			else if( t.socks.remove(m.s) ) {
				var infos : ClientInfos<Client> = m.s.custom;
				work(doClientDisconnected.bind(m.s,infos.client));
			}
		}
	}

	function doClientDisconnected(s,c) {
		try s.close() catch( e : Dynamic ) {};
		clientDisconnected(c);
	}

	function runWorker() {
		while( true ) {
			var f = Thread.readMessage(true);
			try {
				f();
			} catch( e : Dynamic ) {
				logError(e);
			}
			try {
				afterEvent();
			} catch( e : Dynamic ) {
				logError(e);
			}
		}
	}

	public function work( f : Void -> Void ) {
		worker.sendMessage(f);
	}

	function logError( e : Dynamic ) {
		var stack = haxe.CallStack.exceptionStack();
		if( Thread.current() == worker )
			onError(e,stack);
		else
			work(onError.bind(e,stack));
	}

	function addClient( sock : Socket ) {
		var start = Std.random(nthreads);
		for( i in 0...nthreads ) {
			var t = threads[(start + i)%nthreads];
			if( t.socks.length < maxSockPerThread ) {
				var infos : ClientInfos<Client> = {
					thread : t,
					client : clientConnected(sock),
					sock : sock,
					buf : haxe.io.Bytes.alloc(initialBufferSize),
					bufpos : 0,
				};
				sock.custom = infos;
				infos.thread.t.sendMessage({ s : sock, cnx : true });
				return;
			}
		}
		refuseClient(sock);
	}

	function refuseClient( sock : Socket) {
		// we have reached maximum number of active clients
		sock.close();
	}

	function runTimer() {
		var l = new Lock();
		while( true ) {
			l.wait( updateTime );
			work( update );
		}
	}

	function init() {
		worker = Thread.create(runWorker);
		timer = Thread.create(runTimer);
		for( i in 0...nthreads ) {
			var t = {
				id : i,
				t : null,
				socks : new Array(),
				p : new Poll(maxSockPerThread),
			};
			threads.push(t);
			t.t = Thread.create(runThread.bind(t));
		}
	}

	public function addSocket( s : Socket ) {
		s.setBlocking( false );
		work( addClient.bind( s ) );
	}

	public function run( host : String, port : Int ) {
		sock = new Socket();
		sock.bind( new sys.net.Host( host ), port );
		sock.listen( listen );
		init();
		while( true ) {
			try {
				addSocket( sock.accept() );
			} catch( e : Dynamic ) {
				logError(e);
			}
		}
	}

	public function sendData( s : sys.net.Socket, data : String ) {
		try {
			s.write(data);
		} catch( e : Dynamic ) {
			stopClient(s);
		}
	}

	public function stopClient( s : Socket ) {
		var infos : ClientInfos<Client> = s.custom;
		try s.shutdown(true,true) catch( e : Dynamic ) { };
		infos.thread.t.sendMessage({ s : s, cnx : false });
	}

	// --- CUSTOMIZABLE API ---

	public dynamic function onError( e : Dynamic, stack ) {
		var estr = try Std.string(e) catch( e2 : Dynamic ) "???" + try "["+Std.string(e2)+"]" catch( e : Dynamic ) "";
		errorOutput.writeString( estr + "\n" + haxe.CallStack.toString(stack) );
		errorOutput.flush();
	}

	public dynamic function clientConnected( s : sys.net.Socket ) : Client {
		return null;
	}

	public dynamic function clientDisconnected( c : Client ) {
	}

	public dynamic function readClientMessage( c : Client, buf : haxe.io.Bytes, pos : Int, len : Int ) : { msg : Message, bytes : Int } {
		return {
			msg : null,
			bytes : len,
		};
	}

	public dynamic function clientMessage( c : Client, msg : Message ) {
	}

	public dynamic function update() {
	}

	public dynamic function afterEvent() {
	}

}
