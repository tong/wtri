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

class WebServerClient {

	public static var defaultIndexFileNames : Array<String> = ['index'];
	public static var defaultIndexFileTypes : Array<String> = ['html'];

	static var EREG_PARAM = ~/([a-zA-Z0-9_])=([a-zA-Z0-9_])/;

	public var path : String;
	public var mime : Map<String,String>;
	public var indexFileNames : Array<String>;
	public var indexFileTypes : Array<String>;
	public var bufSize : Int;

	var server : WebServer;
	var socket : Socket;
	var o : haxe.io.Output;
	var request : HTTPClientRequest;
	var returnCode : ReturnCode;
	var headers : Headers;

	public function new( server : WebServer,
						 socket : Socket,
						 path : String,
						 ?mime : Map<String,String>,
						 ?indexFileNames : Array<String>, ?indexFileTypes : Array<String>,
						 bufSize : Int = 1024 ) {
		
		if( mime == null ) {
			mime = [
				'css' => 'text/css',
				'gif' => 'image/gif',
				'html' => 'text/html',
				'jpg' => 'image/jpeg',
				'jpeg' => 'image/jpeg',
				'js' => 'application/javascript',
				'png' => 'image/png',
				'txt' => 'text/plain',
				'xml' => 'text/xml',
				'wav' => 'audio/x-wav',
				'mp3' => 'audio/mpeg',
				'ogg' => 'application/ogg',
				'php' => 'text/php'
			];
		}
		if( indexFileNames == null ) indexFileNames = defaultIndexFileNames;
		if( indexFileTypes == null ) indexFileTypes = defaultIndexFileTypes;

		this.server = server;
		this.socket = socket;
		this.path = path;
		this.mime = mime;
		this.indexFileNames = indexFileNames;
		this.indexFileTypes = indexFileTypes;
		this.bufSize = bufSize;

		o = socket.output;
	}

	/*
	// TODO
	public function close() {
		if( socket != null ) {
			//stopClient();
			try socket.close() catch(e:Dynamic){
				trace(e);
			}
		} 
	}
	*/

	/**
	*/
	public function cleanup() {
	}

	/**
		Read client input
	*/
	public function read( buf : Bytes, pos : Int, len : Int ) : HTTPClientRequest {
		//trace( "###################################### read" );
		var i = new BytesInput( buf, pos, len );
		var line = i.readLine();
		var r = ~/(GET|POST) \/(.*) HTTP\/(1\.1)/;
		if( !r.match( line ) ) {
			sendError( 400, 'Bad Request' );
			return null;
		}
		//TODO
		if( r.matched(1) == 'POST' ) {
			//TODO
			trace("TODO http post");
		}
		var url = r.matched(2);
		var version = r.matched(3);
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
				return null;
			}
			request.headers.set( r.matched(1), r.matched(2) );
		}
		request.ctype = request.headers.get( 'Content-Type' );
		return request;
	}

	/**
		Process client http request.
	*/
	public function processRequest( r : HTTPClientRequest ) {
		
		#if dev_server
		//trace( "###################################### processRequest" );
		#end

		returnCode = { code : 200, text : "OK" };
		
		headers = createResponseHeader();

		var url = r.url;
		var fpath : String = null;
		try fpath = findFile( r.url ) catch( e : Dynamic ) {
			sendError( 500, 'Internal Server Error' );
			return;
		}
		if( fpath == null ) {
			//if( showFileIndex ) //TODO
			returnCode.code = 404;
			var s = '404 - Not Found';
			headers.set( 'Content-Length', Std.string( s.length ) );
			sendHeaders();
			o.writeString( s );
		} else {
			var ext = fpath.substr( fpath.lastIndexOf( '.' )+1 );
			var ctype = mime.exists( ext ) ? mime.get( ext ) : 'unknown/unknown';
			headers.set( 'Content-Type', ctype );
			var fullPath = this.path + fpath;
			switch( ext ) {
			//TODO params
			case "php":
				//var result = externProcess( 'php', [fullPath].concat( args ) );
				var result = externProcess( 'php', [fullPath] );
				headers.set( 'Content-Length', Std.string( result.length ) );
				sendHeaders();
				o.writeString( result );
			default:
				sendFile( fullPath );
			}
		}
	}

	function createResponseHeader() : Headers {
		return [
			#if dev_server
			'Server' => haxe.WebServer.name
			#end
		];
	}

	function findFile( url : String ) : String {
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

	function sendFile( path : String ) {
		var fstat = FileSystem.stat( path );
		var size = fstat.size;
		headers.set( 'Content-Length', Std.string( size ) );
		sendHeaders();
		var fi = File.read( path, true );
		if( size < bufSize )
			o.writeInput( fi, size );
		else {
			//TODO http partial
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
	}

	function sendError( status : Int, ?content : String ) {
		returnCode.code = status;
		if( content != null )
			headers.set( 'Content-Length', Std.string( content.length ) );
		sendHeaders();
		if( content != null ) o.writeString( content );
	}

	inline function writeLine( s : String = "" ) {
		o.writeString( '$s\r\n' );
	}

	function externProcess( name : String, args : Array<String> ) : String {
		var p = new sys.io.Process( name, args );
		var e = p.stderr.readAll();
		return if( e != null && e.length > 0 ) e.toString(); else p.stdout.readAll().toString();
	}

}
