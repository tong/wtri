package haxe.net;

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.net.Socket;
#elseif js
import js.net.Socket;
#end
import haxe.Template;
import haxe.net.HTTPRequest;
import haxe.net.HTTPStatusCode;

using Lambda;
using StringTools;

class WebServerClient extends
	#if nodejs js.net.WebServerClient
	#elseif sys sys.net.WebServerClient
	#end {

	public var indexFiles : Array<String>;
	public var indexTypes : Array<String>;

	var root : String;
	var templateError : Template;
	var templateIndex : Template;

	public function new( socket : Socket, root : String ) {

		super( socket );
		this.root = root;

		indexFiles = ['index'];
		indexTypes = ['html','htm'];

		templateError = new Template( File.getContent( 'res/error.html' ) );
		templateIndex = new Template( File.getContent( 'res/index.html' ) );
	}

	public override function processRequest( r : HTTPRequest, ?root : String ) {

		super.processRequest( r, root );

		var path = ( root != null ) ? root : this.root;
		path += r.url;

		var filePath = findFile( path );
		if( filePath == null ) {
			fileNotFound( path, r.url );
		} else {
			var contentType : String = null;
			if( r.headers.exists( 'Accept' ) ) {
				var ctype = r.headers.get('Accept');
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
			sendFile( filePath );
		}

		logHTTPRequest( r );
	}

	override function createResponseHeaders() : HTTPHeaders {
		var h = super.createResponseHeaders();
		h.set( 'Server', WebServer.name );
		return h;
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
		for( f in FileSystem.readDirectory( path) ) {
			if( r.match( f ) ) {
				return path + r.matched(1) + '.' + r.matched(2);
			}
		}
		return null;
	}

	function fileNotFound( path : String, url : String, ?html : String ) {
		if( !FileSystem.exists( path ) || !FileSystem.isDirectory( path ) ) {
			if( html == null )
				html = templateError.execute( { code : HTTPStatusCode.NOT_FOUND, status : 'Not Found', content : '<h1>404 Not Found</h1>' } );
			sendData( html );
			return;
		}
		var now = Date.now();
		var dirs = [], files = [];
		for( f in FileSystem.readDirectory( path ) ) {
			var p = path+f;
			var fstat = FileSystem.stat( p );
			var mtime = fstat.mtime;
			var modified = '';
			if( now.getFullYear() != mtime.getFullYear() ) modified += mtime.getFullYear()+'-';
			#if cpp
			modified += Date.now().toString();
			#elseif neko
			modified += DateTools.format( mtime, '%d-%B %H:%M:%S' );
			#end
			var o : Dynamic = { name : f, path : f, modified : modified };
			if( FileSystem.isDirectory( p ) ) {
				o.items = FileSystem.readDirectory( p ).length;
				dirs.push( o );
			} else {
				o.size = if( fstat.size > 1024*1024 ) Std.int( fstat.size/(1024*1024) )+'MB';
					else if( fstat.size > 1024 ) Std.int( fstat.size/1024 )+'KB';
					else fstat.size;
				files.push( o );
			}
		}
		var ctx = {
			//parent : '../',
			path : url,
			dirs : dirs,
			files : files, 
			address : WebServer.name+' '+socket.host().host+':'+socket.host().port,
		};
		sendData( templateIndex.execute( ctx ) );
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

	function logHTTPRequest( r : HTTPRequest ) {
		var log = new StringBuf();
		var now = Date.now();
		var time = DateTools.format( Date.now(), '%d/%b/%Y|%H:%M:%S' );
		log.add( time );
		log.add( ' - ' );
		log.add( if( r.method == null ) 'GET' else Std.string( r.method ).toUpperCase() );
		log.add( ' - ' );
		log.add( '"'+(if( r.url == null || r.url.length == 0 ) '/' else r.url )+'"' );
		Sys.println( log.toString() );
	}
}

/**
	Development web server
*/
class WebServer extends
	#if nodejs js.net.WebServer<WebServerClient>
	#elseif sys sys.net.WebServer<WebServerClient>
	#end {

	public static inline var VERSION = '0.2';

	public static var name = "Haxe Development Server";

	/** Servers root path in filesystem */
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
		trace("clientConnected");
		return new WebServerClient( s, root );
	}

	#if haxe_dev_server

	static function main() {
		var host = 'localhost';
		var port = 80;
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

	#end
	
}
