package sys.net;

import sys.net.Socket;
import haxe.io.Bytes;
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

@:require(cpp||neko)
class ThreadSocketServer<Client,Message> {

	public dynamic function clientConnected( s : Socket ) : Client return null;
	public dynamic function clientDisconnected( c : Client ) {}
	public dynamic function readClientMessage( c : Client, buf : Bytes, pos : Int, len : Int ) : { msg : Message, len: Int } { return { msg : null, len : len }; }
	public dynamic function clientMessage( c : Client, m : Message ) {}
	public dynamic function update() {}
	public dynamic function afterEvent() {}
	public dynamic function onError( e : Dynamic, stack ) {
		var s = try Std.string(e) catch(e2:Dynamic) "???" + try "["+Std.string(e2)+"]" catch(e:Dynamic) "";
		errorOutput.writeString( s + "\n" + haxe.CallStack.toString( stack ) );
		errorOutput.flush();
	}

	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var numConnections : Int;

	public var nthreads : Int;
	public var connectLag : Float;
	public var errorOutput : haxe.io.Output;
	public var initialBufferSize : Int;
	public var maxBufferSize : Int;
	public var messageHeaderSize : Int;
	public var updateTime : Float;
	public var maxSockPerThread : Int;

	var threads : Array<ThreadInfos>;
	var sock : Socket;
	var worker : Thread;
	var timer : Thread;

	public function new( host : String, port : Int ) {
		//super( host, port );
		this.host = host;
		this.port = port;
		threads = new Array();
		nthreads = if( Sys.systemName() == "Windows" ) 150 else 10;
		messageHeaderSize = 1;
		numConnections = 10;
		connectLag = 0.5;
		errorOutput = Sys.stderr();
		initialBufferSize = (1 << 10);
		maxBufferSize = (1 << 16);
		maxSockPerThread = 64;
		updateTime = 1;
	}

	public function start() {
		sock = new Socket();
		sock.bind( new sys.net.Host( host ), port );
		sock.listen( numConnections );
		init();
		while( true )
			try addSocket( sock.accept() ) catch(e:Dynamic) logError(e);
	}

	public function addSocket( s : Socket ) {
		s.setBlocking( false );
		work( addClient.bind( s ) );
	}

	public function stopClient( s : Socket ) {
		var infos : ClientInfos<Client> = s.custom;
		try s.shutdown(true,true) catch( e : Dynamic ) {};
		infos.thread.t.sendMessage( { s : s, cnx : false } );
	}

	public function sendData( s : Socket, data : String ) {
		try s.write( data ) catch( e : Dynamic ) stopClient( s );
	}

	public function work( f : Void->Void ) {
		worker.sendMessage(f);
	}

	function runThread( t : ThreadInfos ) {
		while( true ) {
			try loopThread(t) catch( e : Dynamic ) {
				logError(e);
			}
		}
	}

	function readClientData( c : ClientInfos<Client> ) {
		var available = c.buf.length - c.bufpos;
		if( available == 0 ) {
			var nsize = c.buf.length * 2;
			if( nsize > maxBufferSize ) {
				nsize = maxBufferSize;
				if( c.buf.length == maxBufferSize )
					throw "Max buffer size reached";
			}
			var nbuf = Bytes.alloc( nsize );
			nbuf.blit( 0, c.buf, 0, c.bufpos );
			c.buf = nbuf;
			available = nsize - c.bufpos;
		}
		var bytes = c.sock.input.readBytes( c.buf, c.bufpos, available );
		var pos = 0;
		var len = c.bufpos + bytes;
		while( len >= messageHeaderSize ) {
			var m = readClientMessage( c.client, c.buf, pos, len );
			if( m == null )
				break;
			pos += m.len;
			len -= m.len;
			work( clientMessage.bind( c.client, m.msg ) );
		}
		if( pos > 0 )
			c.buf.blit( 0, c.buf, pos, len );
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
			var m : { s : Socket, cnx : Bool } = Thread.readMessage( t.socks.length == 0 );
			if( m == null )
				break;
			if( m.cnx )
				t.socks.push( m.s );
			else if( t.socks.remove( m.s ) ) {
				var infos : ClientInfos<Client> = m.s.custom;
				work( doClientDisconnected.bind( m.s, infos.client ) );
			}
		}
	}

	function doClientDisconnected( s : Socket, c : Client ) {
		try s.close() catch( e : Dynamic ) {};
		clientDisconnected(c);
	}

	function runWorker() {
		while( true ) {
			var f = Thread.readMessage(true);
			try f() catch( e : Dynamic ) logError(e);
			try afterEvent() catch( e : Dynamic ) logError(e);
		}
	}

	function logError( e : Dynamic ) {
		var stack = haxe.CallStack.exceptionStack();
		if( Thread.current() == worker )
			onError( e, stack );
		else
			work( onError.bind( e, stack ) );
	}

	function addClient( s : Socket ) {
		var start = Std.random( nthreads );
		for( i in 0...nthreads ) {
			var t = threads[(start + i)%nthreads];
			if( t.socks.length < maxSockPerThread ) {
				var infos : ClientInfos<Client> = {
					thread : t,
					client : clientConnected( s ),
					sock : s,
					buf : haxe.io.Bytes.alloc(initialBufferSize),
					bufpos : 0,
				};
				s.custom = infos;
				infos.thread.t.sendMessage( { s : s, cnx : true } );
				return;
			}
		}
		refuseClient(s);
	}

	function refuseClient( s : Socket) {
		s.close(); // we have reached maximum number of active clients
	}

	function runTimer() {
		var l = new Lock();
		while( true ) {
			l.wait( updateTime );
			work( update );
		}
	}

	function init() {
		worker = Thread.create( runWorker );
		timer = Thread.create( runTimer );
		for( i in 0...nthreads ) {
			var t = {
				id : i,
				t : null,
				socks : new Array(),
				p : new Poll( maxSockPerThread ),
			};
			threads.push(t);
			t.t = Thread.create( runThread.bind( t ) );
		}
	}

}
