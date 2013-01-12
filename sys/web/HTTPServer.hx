package sys.web;

import haxe.io.Bytes;
import sys.net.Socket;

class HTTPServer extends sys.net.RealtimeSocketServer<HTTPServerClient> {

	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var path(default,null) : String;

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
		return new HTTPServerClient( s, path );
	}
	
	public override function readClientMessage( c : HTTPServerClient, buf : Bytes, pos : Int, len : Int ) : Int {
		var n = c.readData( buf, pos, len );
		//c.close();
		return n;
	}
	
	public override function clientDisconnected( c : HTTPServerClient ) {
		//c.cleanup();
		//neko.vm.Gc.run( true );
	}

	#if wtri_standalone

	static inline function log( t : Dynamic ) {
		Sys.println( t );
	}

	static function main() {
		
		var args = Sys.args();
		
		//TODO
		var ip = "localhost";
		var port = 1234;
		var path = "test/";//Sys.getCwd();

		//log( "WTRI" );

		var server = new HTTPServer( path );

		var m = "Starting http server ["+ip+":"+port;
		if( path != null ) m += ":"+path;
		Sys.println( m + "]" );
		
		server.run( ip, port );
	}

	#end

}
