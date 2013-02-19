package sys.web;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import sys.net.Socket;

private enum HTTPMethod {
	get;
	post;
	custom( t : String );
}

private typedef HTTPRequest = {
	?method : HTTPMethod,
	?res : String,
	url : String,
	version : String,
	?ctype : String
	//var headers : Hash<String>
	//var params : Hash<String>;
	//var postData : String;
}

private typedef ReturnCode = {
	var code : Int;
	var text : String;
}

class HTTPServerClient {

	public var mime : Map<String,String>;
	public var indexMimeTypes : Array<String>;
	public var path : String;
	public var bufsize : Int;
	public var printDirectoryIndex : Bool;

	var server : HTTPServer;
	var socket : Socket;
	var o : haxe.io.Output;
	var headers : Map<String,String>;
	var returnCode : ReturnCode;

	public function new( server : HTTPServer, socket : Socket, path : String,
						 bufsize : Int = 512,
						 printDirectoryIndex : Bool = true ) {
		
		this.server = server;
		this.socket = socket;
		this.path = path;
		this.bufsize = bufsize;
		this.printDirectoryIndex = printDirectoryIndex;
		
		o = socket.output;

		mime = new Map();
		mime.set( "gif", "image/gif" );
		mime.set( "jpeg", "image/jpeg" );
		mime.set( "jpg", "image/jpeg" );
		mime.set( "png", "image/png" );
		mime.set( "css", "text/css" );
		mime.set( "html", "text/html" );
		mime.set( "htm", "text/html" );
		mime.set( "txt", "text/plain" );
		mime.set( "js", "application/javascript" );
		mime.set( "pdf", "application/pdf" );
		mime.set( "xml", "text/xml" );
		mime.set( "wav", "audio/x-wav" );
		mime.set( "mp3", "audio/mpeg" );
		mime.set( "ogg", "application/ogg" );
		mime.set( "php", "text/php" );

		indexMimeTypes = ["html","n","txt","php"];
	}

	public function readData( buf : Bytes, pos : Int, len : Int ) : Int {

		headers = new Map();
		returnCode = { code : 200, text : "OK" };

		var i = new BytesInput( buf, pos, len );
		var t = i.readLine();
		var r = ~/(GET|POST) \/(.*) HTTP\/(1\.1)/;
		if( !r.match( t ) ) {
			trace( "invalid http [$t]" );
			//TODO
			return null;
		}
		var req : HTTPRequest = {
			method : Type.createEnum( HTTPMethod, r.matched(1).toLowerCase() ), //TODO
			url : r.matched(2),
			version : r.matched(3),
		};
		r = ~/([a-zA-Z-]+): (.+)/;
		while( ( t = i.readLine() ) != "" ) {
			if( !r.match( t ) )
				return null;
			headers.set( r.matched(1), r.matched(2) );
		}
		req.res = StringTools.urlDecode( req.url ); //?
		req.ctype = headers.get( "Content-Type" );
		if( req.method == post ) {
			//TODO read post content
		}

		trace( socket.peer().host+" - "+Date.now().toString()+" - "+req );

		//TODO
		//if( req.res == "server:config" ) {
		//if( processCustomPath( req ) ) {

		var fpath = findFile( req.res );
		if( fpath == null ) {
			var p = path+req.url;
			if( printDirectoryIndex && FileSystem.exists( p ) && FileSystem.isDirectory( p ) ) {
				send( createDirectoryIndexHTML( req.res ) );
			} else {
				send( create404HTML( req.res ) );
			}
		} else {
			var ext = fpath.substr( fpath.lastIndexOf(".")+1 );
			var ctype = mime.exists( ext ) ? mime.get( ext ) : "unknown/unknown";
			headers.set( "Content-Type", ctype );
			switch( ext ) {
			case "php":
				sendBytes( external( "php", [fpath] ) );
			case "n":
				sendBytes( external( "n", [fpath] ) );
			default:
				var fstat = FileSystem.stat( fpath );
				var size = fstat.size;
				headers.set( "Content-Length", Std.string( size ) );
				sendHeaders();
				var fi = File.read( fpath, true );
				//o.writeInput( fi, size );
				if( size < bufsize )
					o.writeInput( fi, size );
				else {
					//TODO partial
					var sent = 0;
					var l = ( size < bufsize ) ? size : bufsize;
					while( true ) {
						o.writeInput( fi, l );
						sent += l;
						if( sent == size )
							break;
						l = size-sent;
						if( l > bufsize ) l = bufsize;
					}
				}
				fi.close();
			}
		}
		return len;
	}

	function findIndexFile( dir : String ) {
		var r = ~/(index\.)(html|html|php|n|txt)/;
		//var r = new EReg( "(index.)("+indexMimeTypes.join("|")+")", null );
		for( f in FileSystem.readDirectory( dir ) ) {
			if( r.match( f ) )
				return dir+r.matched(1)+r.matched(2);
		}
		return null;
	}

	function findFile( url : String ) : String {
		if( url.length == 0 )
			return findIndexFile( path );
		var p = path + url;
		if( !FileSystem.exists( p ) )
			return null;
		return FileSystem.isDirectory( p ) ? findIndexFile( p+"/" ) : p;
	}

	function sendHeaders() {
		o.writeString( "HTTP/1.1 $returnCode.code $returnCode.text\r\n" );
		for( k in headers.keys() )
			o.writeString( k+": "+headers.get( k )+"\r\n" );
		o.writeString( "\r\n" );
	}

	function send( t : String ) {
		headers.set( "Content-Length", Std.string( t.length ) );
		sendHeaders();
		o.writeString( t );
	}

	inline function sendBytes( b : Bytes ) {
		send( b.toString() );
	}

	//function formatContent( t : String ) : String {

	function create404HTML( url : String ) {
		return "404 - "+url;
	}

	function createDirectoryIndexHTML( path : String ) : String {
		var p = this.path + path;
		var b = new StringBuf();
		b.add( "<html><head><title>" );
		b.add( path );
		b.add( "</title></head><body>" );
		b.add( '<h1>Index of '+path+'</h1>' );
		b.add( "<table>" );
		if( path != "" )
			b.add( '<tr><td valign="top"><a href="../">..</a></td></tr>' );
		var dirs = new Array<String>();
		var files = new Array<String>();
		for( f in FileSystem.readDirectory( p ) )
			FileSystem.isDirectory( p+"/"+f ) ? dirs.push( f ) : files.push( f );
		for( f in dirs ) {
			//var fstat = FileSystem.stat( p+"/"+f );
			b.add( '<tr><td valign="top"><a href="$f/">[$f]</a></td></tr>' );
		}
		for( f in files ) {
			var fstat = FileSystem.stat( p+"/"+f );
			b.add( '<tr><td valign="top"><a href="$f">$f</a></td>' );
			b.add( '<td>  - </td>' );
			b.add( '<td>'+fstat.mtime+'</td>' );
			b.add( '<td>  - </td>' );
			b.add( '<td>'+fstat.size+'</td>' );
			b.add( "</tr>" );
		}
		b.add( '<tr><th colspan="5"><hr></th></tr>' );
		b.add( '</table>' );
		b.add( '<address>WTri http server '+server.host+' Port '+server.port+'</address>' );
		b.add( '</body></html>' );
		return b.toString();
	}

	//function createStatusHTML()
	//function createBaseHTML()

	static function external( name : String, args : Array<String> ) : Bytes {
		var p = new sys.io.Process( name, args );
		var e = p.stderr.readAll();
		var r = p.stdout.readAll();
		p.close();
		if( r != null )
			return r;
		return e;
	}

}
