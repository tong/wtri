package sys.net;

import sys.net.Socket;
import haxe.io.Bytes;

class SocketServer<Client:SocketServerClient,Message> {
	
	public dynamic function clientConnected( s : Socket ) : Client return null;
	public dynamic function clientDisconnected( c : Client ) {}
	public dynamic function readClientMessage( c : Client, buf : Bytes, pos : Int, len : Int ) : { msg : Message, len: Int } { return { msg : null, len : len }; }
	public dynamic function clientMessage( c : Client, m : Message ) {}
	public dynamic function update() {}
	public dynamic function afterEvent() {}
	public dynamic function onError( e : Dynamic, stack ) {
		var s = try Std.string(e) catch(e2:Dynamic) "???" + try "["+Std.string(e2)+"]" catch(e:Dynamic) "";
		trace(s);
		//TODO
//		errorOutput.writeString( s + "\n" + haxe.CallStack.toString( stack ) );
//		errorOutput.flush();
	}

	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var connected(default,null) : Bool;
	public var numConnections : Int;

	var sock : Socket;
	var bufSize : Int;
	var bufPos : Int;
	var buf : Bytes;
	var client : Socket;

	public function new( host : String, port : Int ) {
		this.host = host;
		this.port = port;
		connected = false;
		numConnections = 1;
		bufSize = 512;
		bufPos = 0;
	}

	public function start() {
		sock = new Socket();
		sock.bind( new Host( host ), port );
		sock.listen( numConnections );
		while( true ) {
			var s = sock.accept();
			s.setBlocking( true );
			var c = clientConnected( s );
			connected = true;
			buf = Bytes.alloc( bufSize );
			bufPos = 0;
			while( connected ) {
				var b = readSocket( s, buf, bufPos, bufSize );
				if( b != null ) {
					readClientMessage( c, b, 0, b.length );
				}

				/*
				var available = buf.length - bufpos;
				if( available == 0 ) {
					var nsize = buf.length * 2;
					//TODO if( newsize > maxBufferSize ) {
					var nbuf = Bytes.alloc( nsize );
					buf = nbuf;
					available = nsize - bufpos;
				}
				var bytes = s.input.readBytes( buf, bufpos, available );
				if( bytes < available ) {
					readClientMessage( c, buf, 0, buf.length );
					buf = Bytes.alloc( bufsize );
					bufpos = 0;
				} else {
					bufpos += bytes;
				}
				*/
			}
		}
	}

	public function send( data : String ) {
		sock.write( data );
		//try s.write( data ) catch( e : Dynamic ) stopClient( s );
	}

	static function readSocket( s : Socket, buf : Bytes, bufPos : Int, bufSize : Int ) : Bytes {
		var available = buf.length - bufPos;
		if( available == 0 ) {
			var nsize = buf.length * 2;
			//TODO if( newsize > maxBufferSize ) {
			var nbuf = Bytes.alloc( nsize );
			buf = nbuf;
			available = nsize - bufPos;
		}
		var bytes = s.input.readBytes( buf, bufPos, available );
		if( bytes < available ) {
			buf = Bytes.alloc( bufSize );
			bufPos = 0;
			//readClientMessage( c, buf, 0, buf.length );
			return buf;
		} else {
			bufPos += bytes;
		}
		trace("##############################");
		return null;
	}

}
