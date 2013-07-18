package wtri;

import sys.FileSystem;
import sys.WebServerClient;
import sys.net.Socket;
import haxe.Resource;
import haxe.Template;

using Lambda;
using StringTools;

/**
	Development web server
*/
@:require(sys)
class WebServer extends sys.WebServer<Client> {

	static inline var VERSION = '0.2';
	static var HELP = 'Wtri Web Server $VERSION
  Usage : wtri <host> <port> <path>
    help : Display this list of options';

	public static var name = 'Haxe Development Server';
	public static var verbose = true;

	override function clientConnected( s : Socket ) : Client {
		return new Client( s, path );
	}

	static inline function exit( ?m: String ) {
		if( m != null ) Sys.println( m );
		Sys.exit(0);
	}

	static function main() {

		var args = Sys.args();
		switch( args[0] ) {
		case 'help':
			exit( HELP );
		case 'version':
			exit( VERSION );
		}
		var host = 'localhost';
		var port = 9990;
		var path = Sys.getCwd();
		if( args[0] != null ) host = args[0];
		if( args[1] != null ) port = Std.parseInt( args[1] );
		if( args[2] != null ) path = args[2];

		var srv = new WebServer( host, port, path );
		//srv.clientMessage = function(c,m) {}
		if( verbose ) Sys.println( 'Starting web server at $host:$port:$path' );
		try srv.start() catch(e:Dynamic) {
			Sys.println( 'wtri error : $e' );
		}
	}
}

private class Client extends sys.WebServerClient {

	override function processRequest( r : HTTPClientRequest, ?customRoot : String ) {
		//trace( "---------------------- processRequest "+r.url  );
		super.processRequest( r, customRoot );
		logHTTPRequest( r );
	}

	/*
	override function fileNotFound( path : String, url : String, ?content : String ) {
		//trace( "fileNotFound "+path+" : "+url);
		super.fileNotFound( path, url, content );
	}
	*/

	override function createResponseHeaders() : HTTPHeaders {
		var h = super.createResponseHeaders();
		h.set( 'Server', WebServer.name );
		return h;
	}

	function logHTTPRequest( r : HTTPClientRequest ) {
		if( WebServer.verbose ) {
			var s = new StringBuf();
			var now = Date.now();
			var time = DateTools.format( Date.now(), '%d/%b/%Y %H:%M:%S %z' );
			s.add( time );
			s.add( ' - ' );
		//	s.add( socket.peer().host.ip );
		//	s.add( ':' );
		//	s.add( socket.peer().port );
	//		s.add( ' - ' );
			s.add( if( r.method == null ) 'GET' else Std.string( r.method ).toUpperCase() );
			s.add( ' - ' );
			s.add( '"'+(if( r.url == null || r.url.length == 0 ) '/' else r.url)+'"' );
			//TODO
		//	if( r.params.array().count() > 0 ) r.params.array().join('/');
		//	s.add( ' - ' );
		//	s.add( r.headers.get('User-Agent') );
			Sys.println( s.toString() );
		}
	}

}
