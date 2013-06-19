package sys;

import sys.net.Socket;
import sys.net.ThreadSocketServer;
import haxe.io.Bytes;

class WebSocketServer extends ThreadSocketServer<WebSocketServerClient,String> {

	public var host(default,null) : String;
	public var port(default,null) : Int;

	public function new( host : String, port : Int ) {
		super();
		this.host = host;
		this.port = port;
	}

	public function start() {
		run( host, port );
	}

	/*
	//TODO
	public function stop() {
		//active = false;
	}
	*/

	public override function clientConnected( s : Socket ) : WebSocketServerClient {
		trace( 'client connected ['+s.peer()+']' );
		return new WebSocketServerClient( s );
	}


	override function clientDisconnected( c : WebSocketServerClient ) {
		trace( "client disconnected " );
 	}

 	override function readClientMessage( c : WebSocketServerClient, buf : Bytes, pos : Int, len : Int ) {
		var r = c.read( buf, pos, len );
		if( r == null )
			return null;
		c.processData( r );
		return { msg : null, bytes : len }
	}
	
}
