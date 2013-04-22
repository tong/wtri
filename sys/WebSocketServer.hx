package sys;

import sys.net.Socket;
import sys.net.RealtimeSocketServer;
import haxe.io.Bytes;

class WebSocketServer extends RealtimeSocketServer<WebSocketServerClient> {

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
		trace( 'Client connected ['+s.peer()+']' );
		return new WebSocketServerClient( s );
	}


	override function clientDisconnected( c : WebSocketServerClient ) {
		trace( "Client disconnected " );
 	}

	public override function readClientMessage( c : WebSocketServerClient, buf : Bytes, pos : Int, len : Int ) {
		var r = c.read( buf, pos, len );
		if( r == "handshaked" )
			return len;
		if( r == null )
			return null;
		trace( "Client message: "+r );
		c.processData( r );
		return len;
	}

	#if dev_server

	static function main() {
		var host = 'localhost';
		var port = 7000;
		//TODO validate args
		var args = Sys.args();
		if( args[0] != null ) host = args[0];
		if( args[1] != null ) port = Std.parseInt( args[1] );
		var server = new WebSocketServer( host, port );
		trace( 'Starting development websocket server : $host:$port' );
		server.start();
	}

	#end
}
