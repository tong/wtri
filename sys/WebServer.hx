package sys;

import haxe.io.Bytes;
import sys.net.Socket;
import sys.net.ThreadSocketServer;

class WebServer extends ThreadSocketServer<WebServerClient,String> {


	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var path(default,null) : String;
	//public var verbose : Bool = false;
	//public var showFileIndex : Bool = false;

	public function new( host : String, port : Int,
						 path : String ) {

		if( !StringTools.endsWith( path, "/" ) ) path += "/";

		super();
		this.host = host;
		this.port = port;
		this.path = path;
	}

	public function start() {
		//active = true;
		run( host, port );
	}

	public function stop() {
		trace("TODO");
		//active = false;
		//sock.close();
		//sock.shutdown( true, true );
	}

	override function clientConnected( s : Socket ) : WebServerClient {
		trace( 'client connected' );
		return new WebServerClient( this, s, path );
	}

	override function clientDisconnected( c : WebServerClient ) {
		trace( 'client disconnected' );
		c.cleanup();
 	}

	override function readClientMessage( c : WebServerClient, buf : Bytes, pos : Int, len : Int ) {
		var r = c.read( buf, pos, len );
		if( r == null )
			return null;
		c.processRequest( r );
		return { msg : null, bytes : len }
	}

}
