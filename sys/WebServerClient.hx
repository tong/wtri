package sys;

import sys.FileSystem;
import sys.io.File;
import sys.net.Socket;
import haxe.HTTPMethod;
import haxe.io.Bytes;
import haxe.io.BytesInput;

using StringTools;

private typedef Headers = Map<String,String>;
private typedef Params = Map<String,String>;

private typedef ReturnCode = {
	var code : Int;
	var text : String;
}

typedef HTTPClientRequest = {
	url : String,
	version : String,
	headers : Headers,
	method : HTTPMethod,
	//res : String,
	?ctype : String,
	params : Params,
	?postData : String
}

/**
	Simple HTTP server
*/
class WebServerClient {

	public static var defaultIndexFileNames : Array<String> = ['index'];
	public static var defaultIndexFileTypes : Array<String> = ['html','n','php'];

	static var EREG_PARAM = ~/([a-zA-Z0-9_])=([a-zA-Z0-9_])/;

	public var path : String;
	public var mime : Map<String,String>;
	public var indexFileNames : Array<String>;
	public var indexFileTypes : Array<String>;
	public var bufSize : Int;

	var socket : Socket;
	var o : haxe.io.Output;
	var request : HTTPClientRequest;
	
	var returnCode : ReturnCode;
	var headers : Headers;

	public function new( socket : Socket,
						 path : String,
						 ?mime : Map<String,String>,
						 ?indexFileNames : Array<String>, ?indexFileTypes : Array<String>,
						 bufSize : Int = 1024 ) {
		
		if( mime == null ) {
			mime = new Map();
			mime.set( 'css', 'text/css' );
			mime.set( 'gif', 'image/gif' );
			mime.set( 'html', 'text/html' );
			mime.set( 'htm', 'text/html' );
			mime.set( 'jpg',' image/jpeg' );
			mime.set( 'jpeg', 'image/jpeg' );
			mime.set( 'js', 'application/javascript' );
			mime.set( 'png', 'image/png' );
			mime.set( 'txt', 'image/plain' );
			mime.set( 'xml', 'text/xml' );
			mime.set( "wav", "audio/x-wav" );
			mime.set( "mp3", "audio/mpeg" );
			mime.set( "ogg", "application/ogg" );
			mime.set( "php", "text/php" );
		}
		if( indexFileNames == null )
			indexFileNames = ['index'];
		if( indexFileTypes == null )
			indexFileTypes = ['html','n','php'];

		this.socket = socket;
		this.path = path;
		this.mime = mime;
		this.indexFileNames = indexFileNames;
		this.indexFileTypes = indexFileTypes;
		this.bufSize = bufSize;

		o = socket.output;
	}

	/**
		Read client input
	*/
	public function read( buf : Bytes, pos : Int, len : Int ) : Int {
		trace("###################################### read");
		var i = new BytesInput( buf, pos, len );
		var line = i.readLine();
		var r = ~/(GET|POST) \/(.*) HTTP\/(1\.1)/;
		if( !r.match( line ) ) {
			sendError( 400, 'Bad Request' );
			return len;
		}
		//TODO
		var ttt = r.matched(1);
		trace(ttt);
		if( ttt == 'POST' ) {
			//TODO
			trace("TODO http post");
		}
		var url = r.matched(2);
		var version = r.matched(3);
		trace("URL: "+url);
		trace("VERSION: "+version);
		var params = new Params();
		var pi = url.indexOf( '?' );
		if( pi != -1 ) {
			var sparams = url.substr( pi );
			url = url.substr( 0, pi );
			trace( url );
			for( p in sparams.split('&') ) {
				trace(p);
				if( !EREG_PARAM.match( p ) ) {
					trace("ERROR");
				}
				trace( EREG_PARAM.matched(1) );
			}
		}
		trace("PARAMS: "+params);
		request = {
			version : version,
			//ctype : headers.get( 'Content-Type' ),
			url : url,
			headers : new Headers(),
			method : HTTPMethod.get, //TODO
			params : params,
		};
		r = ~/([a-zA-Z-]+): (.+)/;
		while( ( line = i.readLine() ) != '' ) {
			if( !r.match( line ) ) {
				//TODO send error
				return len;
			}
			request.headers.set( r.matched(1), r.matched(2) );
		}
		request.ctype = request.headers.get( 'Content-Type' );
		try processHTTPRequest( request ) catch( e : Dynamic ) {
			//TODO
			trace(e);
			sendError( 500, 'Internal Server Error' );
		}
		return len;
	}

	/**
		Process client http request.
		Gets called internally from read(), public to inject/handle custom http requests.
	*/
	public function processHTTPRequest( r : HTTPClientRequest ) {
		#if dev_server
		#end
		//trace( r, socket.peer().host.ip );
		for( p in r.params ) trace( p );
		returnCode = { code : 200, text : "OK" };
		headers = new Headers();
		var url = r.url;
		var fpath : String = null;
		try fpath = findFile( r.url ) catch( e : Dynamic ) {
			sendError( 500, 'Internal Server Error' );
			return;
		}
		if( fpath == null ) {
			returnCode.code = 404;
			var s = '404';
			headers.set( 'Content-Length', Std.string( s.length ) );
			sendHeaders();
			o.writeString( s );
		} else {
			var ext = fpath.substr( fpath.lastIndexOf( '.' )+1 );
			var ctype = mime.exists( ext ) ? mime.get( ext ) : 'unknown/unknown';
			headers.set( 'Content-Type', ctype );
			var fullPath = this.path + fpath;
			trace(fullPath);
			switch( ext ) {
			//TODO params
			case "php":
				//var result = externProcess( 'php', [fullPath].concat( args ) );
				var result = externProcess( 'php', [fullPath] );
				headers.set( 'Content-Length', Std.string( result.length ) );
				sendHeaders();
				o.writeString( result );
			default:
				var fstat = FileSystem.stat( fullPath );
				var size = fstat.size;
				headers.set( 'Content-Length', Std.string( size ) );
				sendHeaders();
				var fi = File.read( fullPath, true );
				if( size < bufSize )
					o.writeInput( fi, size );
				else {
					//TODO partial
					var sent = 0;
					var l = ( size < bufSize ) ? size : bufSize;
					while( true ) {
						o.writeInput( fi, l );
						sent += l;
						if( sent == size )
							break;
						l = size-sent;
						if( l > bufSize )
							l = bufSize;
					}
				}
				fi.close();
				//trace( Date.now().getTime()-__ts );
			}
		}
	}

	function findFile( url : String ) : String {
		#if dev_server
		#end
		//trace( "findFile : "+url  );
		if( url == null || url.length == 0 )
			return findIndexFile( url );
		if( !FileSystem.exists( path+url ) )
			return null;
		if( FileSystem.isDirectory( path+url ) )
			return findIndexFile( url );
		return url;
	}

	function findIndexFile( url : String ) : String {
		#if dev_server
		#end
		//trace( "findIndexFile : "+url  );
		var fnames = indexFileNames.join( '|' );
		var ftypes = indexFileTypes.join( '|' );
		var r = new EReg( '($fnames).($ftypes)$', '' );
		for( f in FileSystem.readDirectory( path+url ) ) {
			if( r.match( f ) )
				return r.matched(1)+'.'+r.matched(2);
		}
		return null;
	}

	function sendHeaders() {
		writeLine( 'HTTP/1.1 ${returnCode.code} ${returnCode.text}' );
		for( k in headers.keys() )
			writeLine( '$k: ${headers.get(k)}' );
		writeLine();
	}

	function sendError( status : Int, ?content : String ) {
		returnCode.code = status;
		sendHeaders();
		if( content != null )
			o.writeString( content );
	}

	inline function writeLine( s : String = "" ) {
		o.writeString( s+'\r\n' );
	}

	function externProcess( name : String, args : Array<String> ) : String {
		var p = new sys.io.Process( name, args );
		var e = p.stderr.readAll();
		var r = p.stdout.readAll();
			trace(e);
			trace(r);
		if( e != null && e.length > 0 ) {
			return e.toString();
		} else if( r != null ) {
			return r.toString();
		}
		return null;
	}
}
