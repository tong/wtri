package sys;

import sys.net.Socket;
import sys.net.ThreadSocketServer;
import haxe.io.Bytes;

class WebSocketServer extends ThreadSocketServer<WebSocketServerClient,String> {

	public var host(default,null) : String;
	public var port(default,null) : Int;

	public function new( host : String, port : Int,
						 path : String ) {

		if( path.charAt( path.length-1 ) != "/" ) path += "/";

		super();
		this.host = host;
		this.port = port;
	}

	public function start() {
		run( host, port );
	}

	public function stop() {
		//TODO
		//active = false;
	}

	public override function clientConnected( s : Socket ) : WebSocketServerClient {
		trace( 'Client connected ['+s.peer()+']' );
		return new WebSocketServerClient( s );
	}

	public override function readClientMessage( c : WebSocketServerClient, buf : Bytes, pos : Int, len : Int ) {
		var len = c.read( buf, pos, len );
		return { msg : null, bytes : len };
	}

	override function clientDisconnected( c : WebSocketServerClient ) {
		trace( "Client disconnected " );
 	}

	#if dev_server

	static function main() {
		
		var host = 'localhost';
		var port = 7000;
		var path = Sys.getCwd();

		//TODO validate args
		var args = Sys.args();
		if( args[0] != null ) host = args[0];
		if( args[1] != null ) port = Std.parseInt( args[1] );
		if( args[2] != null ) path = args[2];
		
		var server = new WebSocketServer( host, port, path );
		trace( 'Starting development websocket server : $host:$port:$path' );
		server.start();
	}

	#end
}
