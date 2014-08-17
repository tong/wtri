package wtri;

import Sys.println;
import sys.FileSystem;
import sys.net.Socket;

using StringTools;
using haxe.io.Path;

/**
	Development web server
*/
class WebServer extends sys.net.WebServer<WebServerClient> {

	public static var name = "Haxe Development Server";

	/* Web server root path in filesystem */
	public var root : String;

	public function new( host : String, port : Int, root : String ) {
		root = FileSystem.fullPath( root.trim() ).addTrailingSlash();
		super( host, port );
		this.root = root;
	}

	public override function start() {
		println( 'Starting webserver: $host:$port:$root' );
		super.start();
	}

	public override function clientConnected( s : Socket ) : WebServerClient {
		return new WebServerClient( s, root );
	}

	public static inline function exit( info : String ) {
		println( info );
		Sys.exit(0);
	}

	public  static inline function error( info : String ) {
		println( info );
		Sys.exit(1);
	}
	
	static function main() {

		var host = 'localhost';
		var port = 2000;
		var root = Sys.getCwd();
		var websocketHost : String;
		var websocketPort : Int;
		
		var args : Dynamic;
		args = hxargs.Args.generate([
			@doc("Host name / IP address") ["-host",'-h','-ip'] => function(v:String) host = v,
			@doc("Port number") ["-port",'-p'] => function(v:String) port = Std.parseInt(v),
			@doc("Root path") ["-root","-r"] => function(v:String) root = v,
			@doc("Get help") ["-help"] => function() exit( args.getDoc() ),
			_ => function(arg:String) {
				println( "Unknown command: " +arg );
				println( args.getDoc() );
				Sys.exit(1);
			}
		]);
		args.parse( Sys.args() );
		
		if( !FileSystem.exists( root ) )
			error( 'Path not found: $root' );
		
		var s = new WebServer( host, port, root );
		try s.start() catch(e:Dynamic) {
			error(e);
		}
	}

}
