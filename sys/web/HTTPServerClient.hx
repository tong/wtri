package sys.web;

import haxe.io.BytesInput;
import sys.FileSystem;
import sys.net.Socket;
import sys.io.File;
import sys.io.Process;
import haxe.io.Bytes;

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

	static function __init__() {
		mime = new Hash();
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

	public static var mime : Hash<String>;
	public static var indexMimeTypes : Array<String>;

	var socket : Socket;
	var path : String;
	var o : haxe.io.Output;
	var bufsize : Int;
	var headers : Hash<String>;
	var returnCode : ReturnCode;

	public function new( socket : Socket, path : String ) {
		this.socket = socket;
		this.path = path;
		o = socket.output;
		bufsize = 512; //1<<8; //1<<14; //16384;
		//indexMimeEReg = new EReg( "(index.)("+indexMimeTypes.join("|")+")", null );
	}

	public function readData( buf : Bytes, pos : Int, len : Int ) : Int {

		headers = new Hash();
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

		Sys.println( socket.peer().host+" - "+Date.now().toString() );

		//if( req.res == "server:config" ) {

		var fpath = findFile( req.res );
		if( fpath == null ) {
			notFound( req.res );
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
		if( url.length == 0 ) {
			return findIndexFile( path );
		} else {
			var p = path + url;
			if( !FileSystem.exists( p ) )
				return null;
			return ( FileSystem.isDirectory( p ) ) ? findIndexFile( p+"/" ) : p;
		}
		return null;
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

	function notFound( url : String ) {
		send( "404 - "+url );
	}

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
