package wtri;

import sys.FileSystem;
import sys.io.File;
import sys.net.Socket;
import haxe.Template;
import haxe.net.HTTPHeaders;
import haxe.net.HTTPRequest;
import haxe.net.HTTPStatusCode;

using StringTools;

class WebServerClient extends sys.net.WebServerClient {

	public var indexFileNames : Array<String>;
	public var indexFileTypes : Array<String>;

	var root : String;

	public function new( socket : Socket, root : String ) {

		super( socket );
		this.root = root;

		mime = [
			'css' 	=> 'text/css',
			'gif' 	=> 'image/gif',
			'html' 	=> 'text/html',
			'jpg' 	=> 'image/jpeg',
			'jpeg' 	=> 'image/jpeg',
			'js' 	=> 'application/javascript',
			//'mp3' 	=> 'audio/mpeg',
			'mpg' 	=> 'audio/mpeg',
			'mpeg' 	=> 'audio/mpeg',
			'ogg' 	=> 'application/ogg',
			//'php' 	=> 'text/php',
			'png' 	=> 'image/png',
			'txt' 	=> 'text/plain',
			'wav' 	=> 'audio/x-wav',
			'xml' 	=> 'text/xml'
		];

		indexFileNames = ['index'];
		indexFileTypes = ['html','htm'];
	}

	/**
		Process http request
	*/
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
				if( mime.exists( ctype ) )
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
		var r = new EReg( '(${indexFileNames.join("|")}).(${indexFileTypes.join("|")})$', '' );
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
				html = createTemplateHtml( 'error', { code : HTTPStatusCode.NOT_FOUND, status : 'Not Found', content : '<h1>404 Not Found</h1>' } );
			sendData( html );
			return;
		}
		var now = Date.now();
		var dirs = new Array<Dynamic>();
		var files = new Array<Dynamic>();
		for( f in FileSystem.readDirectory( path ) ) {
			var p = path+f;
			var stat = FileSystem.stat( p );
			var mtime = stat.mtime;
			var modified = '';
			if( now.getFullYear() != mtime.getFullYear() ) modified += mtime.getFullYear()+'-';
			modified += getDateTime( mtime );
			var o : Dynamic = { name : f, path : f, modified : modified };
			if( FileSystem.isDirectory( p ) ) {
				o.items = FileSystem.readDirectory( p ).length;
				dirs.push( o );
			} else {
				o.size =
					if( stat.size > 1024*1024 ) Std.int( stat.size/(1024*1024) )+'MB';
					else if( stat.size > 1024 ) Std.int( stat.size/1024 )+'KB';
					else stat.size;
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
		sendData( createTemplateHtml( 'index', ctx ) );
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
		var s = new StringBuf();
		var now = Date.now();
		var time = DateTools.format( Date.now(), '%d/%b/%Y|%H:%M:%S' );
		s.add( time );
		s.add( ' - ' );
		s.add( if( r.method == null ) 'GET' else Std.string( r.method ).toUpperCase() );
		s.add( ' - ' );
		s.add( '"'+(if( r.url == null || r.url.length == 0 ) '/' else r.url )+'"' );
		Sys.println( s.toString() );
	}

	static inline function getDateTime( ?time : Date ) : String {
		if( time == null ) time = Date.now();
		return
			#if cpp
			time.toString()
			#else
			DateTools.format( time, '%d-%B %H:%M:%S' )
			#end;
	}

	static inline function createTemplate( id : String ) : Template {
		return new Template( haxe.Resource.getString( id ) );
	}

	static inline function createTemplateHtml( id : String, ctx : Dynamic ) : String {
		return createTemplate( id ).execute( (ctx == null) ? {} : ctx );
	}

}
