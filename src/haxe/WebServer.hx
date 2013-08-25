package haxe;

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.net.Socket;
import sys.net.WebServer;
import sys.net.WebServerClient;
#elseif js
import js.net.Socket;
import js.net.WebServerClient;
#end
import haxe.net.HTTPRequest;
import haxe.net.HTTPStatusCode;

using Lambda;
using StringTools;

class WebServerClient extends sys.net.WebServerClient {

	public var indexFiles : Array<String>;
	public var indexTypes : Array<String>;

	var root : String;

	public function new( socket : Socket, root : String ) {

		super( socket );
		this.root = root;

		indexFiles = ['index'];
		indexTypes = ['html','htm'];
	}

	public override function processRequest( req : HTTPRequest, ?customRoot : String ) {

		super.processRequest( req, customRoot );

		var path = if( customRoot != null ) customRoot else root;
		path += req.url;

		var filePath = findFile( path );
		if( filePath == null ) {
			fileNotFound( path, req.url );
		} else {
			var contentType : String = null;
			if( req.headers.exists( 'Accept' ) ) {
				var ctype = req.headers.get('Accept');
				ctype = ctype.substr( 0, ctype.indexOf(',') ).trim();
				if( mime.has( ctype ) )
					contentType = ctype;
			}
			if( contentType == null ) {
				var ext = filePath.substr( filePath.lastIndexOf( '.' )+1 );
				contentType = mime.exists( ext ) ? mime.get( ext ) : 'unknown/unknown';
			}
			responseHeaders.set( 'Content-Type', contentType );
			/* TODO execute neko modules
			if( r.url.endsWith('.n') ) {
				var l = neko.vm.Loader.local();
				var m = l.loadModule('ext.n',l );
				trace(m);
				//trace( m.execute() );
				sendData("NEKO!");
			}
			*/
			sendFile( path );
		}
	}

	function findFile( path : String ) : String {
		if( !FileSystem.exists( path ) )
			return null;
		if( FileSystem.isDirectory( path ) )
			return findIndexFile( path );
		return path;
	}

	function findIndexFile( path : String ) : String {
		var r = new EReg( '('+indexFiles.join( '|' )+').('+indexTypes.join( '|' )+')$', '' );
		for( f in FileSystem.readDirectory( path) )
			if( r.match( f ) )
				return r.matched(1)+'.'+r.matched(2);
		return null;
	}

	function fileNotFound( path : String, url : String, ?content : String ) {
		if( content == null ) content = '404 Not Found - /$url';
		sendError( HTTPStatusCode.NOT_FOUND, 'Not Found', content );
	}

	function sendFile( path : String ) {
		var stat = FileSystem.stat( path );
		responseHeaders.set( 'Content-Length', Std.string( stat.size ) );
		sendHeaders();
		var f = File.read( path, true );
		//if( size < bufSize ) //TODO
		output.writeInput( f, stat.size );
		//TODO compression
		//output.writeString( neko.zip.Compress.run( f.readAll(), 6 ).toString() );
		f.close();
	}
}

/**
	Development web server
*/
class WebServer extends sys.net.WebServer<haxe.WebServerClient> {

	/** Servers root path in filesystem */
	public var root : String;

	public function new( host : String, port : Int, root : String ) {
		root = root.trim();
		if( !(root=root.trim()).endsWith('/') ) root += '/';
		super( host, port );
		this.root = root;
	}

	public override function start() {
		Sys.println( 'Starting web server : $host:$port:$root' );
		super.start();
	}

	public override function clientConnected( s : Socket ) : haxe.WebServerClient {
		return new haxe.WebServerClient( s, root );
	}

	#if dev_server

	static function main() {
		
		var host = 'localhost';
		var port = 80;
		var root = Sys.getCwd();

		var args = Sys.args();
		var argHandler = hxargs.Args.generate([
			@doc("Host name / IP address") ["-host",'-h','-ip'] => function(v:String) host = v,
			@doc("Set the output path for generated pages") ["-port",'-p'] => function(v:String) port = Std.parseInt(v),
			@doc("Set web servers root path") ["-root","-r"] => function(v:String) root = v,
			//@doc("Show this help") ["-help","--help"] => function() Sys.println( argHandler.getDoc() ),
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

	#end
	
}
