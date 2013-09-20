package wtri;

import sys.FileSystem;
import sys.net.Socket;

using StringTools;

class WebServer extends sys.net.WebServer<WebServerClient> {

	public static var name = "Haxe Development Server";

	/* Web servers root path */
	public var root : String;

	public function new( host : String, port : Int, root : String ) {
		root = root.trim();
		if( !root.endsWith('/') ) root += '/';
		super( host, port );
		this.root = root;
	}

	public override function start() {
		Sys.println( 'Starting web server : $host:$port:$root' );
		super.start();
	}

	public override function clientConnected( s : Socket ) : WebServerClient {
		Sys.println( "Client connected" );
		return new WebServerClient( s, root );
	}

	static function main() {
		var host = 'localhost';
		var port = 2000;
		var root = Sys.getCwd();
		var args = Sys.args();
		var argHandler = hxargs.Args.generate([
			@doc("Host name / IP address") ["-host",'-h','-ip'] => function(v:String) host = v,
			@doc("Set the output path for generated pages") ["-port",'-p'] => function(v:String) port = Std.parseInt(v),
			@doc("Set web servers root path") ["-root","-r"] => function(v:String) root = v,
			_ => function(arg:String) throw "Unknown command: " +arg
		]);
		argHandler.parse( args );
		if( !FileSystem.exists( root ) ) {
			Sys.println( 'Root path not found : $root' );
			Sys.exit( 1 );
		}
		var s = new WebServer( host, port, root );
		try s.start() catch(e:Dynamic) {
			Sys.println( e );
			Sys.exit( 1 );
		}
	}

}
