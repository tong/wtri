package sys.web;

import haxe.io.Bytes;
import sys.net.Socket;

/**
	Embeddable HTTP server.
	Comppile with -D wtri_standalone to build a standalone application.
*/
class HTTPServer extends sys.net.RealtimeSocketServer<HTTPServerClient> {

	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var path(default,null) : String; //TODO paths : Array<String>

	public function new( path : String ) {
		super();
		this.path = ( path == null ) ? Sys.getCwd() : path;
		if( this.path.charAt( this.path.length ) != "/" ) this.path += "/";
	}

	public override function run( host : String, port : Int ) {
		this.host = host;
		this.port = port;
		super.run( host, port );
	}

	public override function clientConnected( s : Socket ) {
		return new HTTPServerClient( this, s, path );
	}
	
	public override function readClientMessage( c : HTTPServerClient, buf : Bytes, pos : Int, len : Int ) : Int {
		return c.readData( buf, pos, len );
	}
	
	/*
	public override function clientDisconnected( c : HTTPServerClient ) {
		//c.cleanup();
		//neko.vm.Gc.run( true );
	}
	*/

	#if wtri_standalone

	static var verbose : Bool = false;

	static function main() {

		var ip = "localhost";
		var port = 7777;
		var path = Sys.getCwd();

		var args = Sys.args();
		if( args[0] != null ) ip = args[0];
		if( args[1] != null ) port = Std.parseInt( args[1] );
		if( args[2] != null ) path = args[2];
		if( args[3] == "v" ) verbose = true;

		var server = new HTTPServer( path );
		Sys.println( "Starting web server : "+ip+":"+port+":"+path );
		server.run( ip, port );
	}

	#end

}
