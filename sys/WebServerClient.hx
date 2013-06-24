package sys;

import sys.FileSystem;
import sys.io.File;
import sys.net.Socket;
import haxe.io.Bytes;
import haxe.io.BytesInput;

using StringTools;

typedef Headers = Map<String,String>;
typedef Params = Map<String,String>;

enum HTTPMethod {
	get;
	post;
	custom( t : String );
}

typedef HTTPClientRequest = {
	url : String,
	version : String,
	headers : Headers,
	method : HTTPMethod,
	//res : String,
	?contentType : String,
	?params : Params,
	?data : String // post data
}

/*
typedef HTTClientResponse = {
}
*/

private typedef ReturnCode = {
	var code : Int;
	var text : String;
}

class WebServerClient {

	public var root : String;
	public var mime : Map<String,String>;
	public var indexFileNames : Array<String>;
	public var indexFileTypes : Array<String>;
	//public var keepAlive : Bool;

	var socket : Socket;
	var out : haxe.io.Output;
	var returnCode : ReturnCode;
	var returnHeaders : Headers;

	public function new( socket : Socket, root : String ) {

		this.socket = socket;
		this.out = socket.output;
		this.root = root;

		mime = [
			'css' => 'text/css',
			'gif' => 'image/gif',
			'html' => 'text/html',
			'hx' => 'text/haxe',
			'jpg' => 'image/jpeg',
			'jpeg' => 'image/jpeg',
			'js' => 'application/javascript',
			'mp3' => 'audio/mpeg',
			'mpg' => 'audio/mpeg',
			'mpeg' => 'audio/mpeg',
			'ogg' => 'application/ogg',
			'php' => 'text/php',
			'png' => 'image/png',
			'txt' => 'text/plain',
			'wav' => 'audio/x-wav',
			'xml' => 'text/xml'
		];

		indexFileNames = ['index'];
		indexFileTypes = ['html','htm'];
		returnCode = { code : 200, text : "OK" };
	}

	/**
		Read HTTP request
	*/
	public function readRequest( buf : Bytes, pos : Int, len : Int ) : HTTPClientRequest {

		var i = new BytesInput( buf, pos, len );
		var line = i.readLine();
		var rexp = ~/(GET|POST) \/(.*) HTTP\/(1\.1)/;
		if( !rexp.match( line ) ) {
			sendError( 400, 'Bad Request' );
			return null;
		}

		var url = rexp.matched(2); //TODO check url, security! no root up
		var version = rexp.matched(3);

		var r : HTTPClientRequest = {
			url : url,
			version : version,
			headers : new Headers(),
			method : null,
			params : new Params(),
			contentType : null
		};

		var _method = rexp.matched(1);
		r.method = switch( _method ) {
		case 'POST': post;
		case 'GET': get;
		default:
			trace("TODO handle http method "+_method );
			null;
		}

		r.headers = new Headers();
		var data : String = null;
		var exp_header = ~/([a-zA-Z-]+): (.+)/;
		while( true ) {
			var line = i.readLine();
			if( line.length == 0 ) {
				if( r.method == post )
					data = i.readLine(); 
				break;
			}
			if( !exp_header.match( line ) ) {
				sendError( 400, 'Bad Request' ); //TODO explicit error
				return null;
			}
			r.headers.set( exp_header.matched(1), exp_header.matched(2) );
		}

		var i = r.url.indexOf( '?' );
		if( i != -1 ) {
			r.params = new Params();
			var s = url.substr( i+1 );
			r.url = r.url.substr( 0, i );
			for( p in s.split('&') ) {
				var parts = p.split( "=" );
				r.params.set( parts[0], parts[1] );
			}
		}

		return r;
	}

	/**
		Process HTTP request
	*/
	public function processRequest( r : HTTPClientRequest, ?customRoot : String ) {
		
		var path = if( customRoot != null ) customRoot else root;
		path += r.url;

		returnHeaders = createResponseHeaders();

		var filePath = findFile( path );
		if( filePath == null ) {
			trace("FILE NOT FOUND "+path);
			//returnCode = { code : 200, text : "OK" };
			fileNotFound( path, r.url );
		} else {
			returnCode = { code : 200, text : "OK" };
			returnHeaders.set( 'Content-Type', r.contentType );
			sendFile( path );
		}
	}

	/**
	*/
	public function cleanup() {
	}

	function findFile( path : String ) : String {
		if( !FileSystem.exists( path ) )
			return null;
		if( FileSystem.isDirectory( path ) )
			return findIndexFile( path );
		return path;
	}

	function findIndexFile( path : String ) : String {
		var r = new EReg( '('+indexFileNames.join( '|' )+').('+indexFileTypes.join( '|' )+')$', '' );
		for( f in FileSystem.readDirectory( path) ) {
			if( r.match( f ) )
				return r.matched(1)+'.'+r.matched(2);
		}
		return null;
	}

	function fileNotFound( path : String, url : String ) {
		sendError( 404, 'Not Found', '404 Not Found - /$url' );
	}

	function createResponseHeaders() : Headers {
		var h = new Headers();
		h.set( 'Date', DateTools.format( Date.now(), '%A, %e %B %Y %I:%M:%S %Z' ) );
		/*
		if( keepAlive ) {
			h.set( 'Connection', 'Keep-Alive' );
			h.set( 'Keep-Alive', 'timeout=5, max=99' );
		}
		*/
		return h;
	}

	function sendData( data : String ) {
		returnHeaders.set( 'Content-Length', Std.string( data.length ) );
		sendHeaders();
		out.writeString( data );
	}

	function sendFile( path : String ) {
		var stat = FileSystem.stat( path );
		returnHeaders.set( 'Content-Length', Std.string( stat.size ) );
		sendHeaders();
		var f = File.read( path, true );
		//if( size < bufSize ) //TODO
		out.writeInput( f, stat.size );
		f.close();
	}

	function sendError( code : Int, status : String, ?content : String ) {
		returnCode = { code : code, text : status };
		if( content != null )
			returnHeaders.set( 'Content-Length', Std.string( content.length ) );
		sendHeaders();
		if( content != null )
			out.writeString( content );
	}

	function sendHeaders() {
		writeLine( 'HTTP/1.1 ${returnCode.code} ${returnCode.text}' );
		for( k in returnHeaders.keys() )
			writeLine( '$k: ${returnHeaders.get(k)}' );
		writeLine();
	}

	inline function writeLine( s : String = "" ) {
		out.writeString( '$s\r\n' );
	}

}
