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

	public var indexFiles : Array<String>;
	public var indexTypes : Array<String>;

	var root : String;
	var tpl_error : Template;
	var tpl_index : Template;

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

		indexFiles = ['index'];
		indexTypes = ['html','htm'];

		tpl_error = new Template( File.getContent( 'res/error.html' ) );
		tpl_index = new Template( File.getContent( 'res/index.html' ) );
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
				html = tpl_error.execute( { code : HTTPStatusCode.NOT_FOUND, status : 'Not Found', content : '<h1>404 Not Found</h1>' } );
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
		sendData( tpl_index.execute( ctx ) );
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
