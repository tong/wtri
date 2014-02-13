package sys.net;

import sys.net.Socket;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.net.HTTPRequest;
import haxe.net.HTTPHeaders;

private typedef HTTPReturnCode = {
	var code : Int;
	var text : String;
}

/**
*/
class WebServerClient {

	public var mime : Map<String,String>;

	var socket : Socket;
	var output : haxe.io.Output;
	var responseCode : HTTPReturnCode;
	var responseHeaders : HTTPHeaders;

	public function new( socket : Socket ) {
		this.socket = socket;
		output = socket.output;
		mime = [
			'css' 	=> 'text/css',
			'gif' 	=> 'image/gif',
			'html' 	=> 'text/html',
			'jpg' 	=> 'image/jpeg',
			'jpeg' 	=> 'image/jpeg',
			'js' 	=> 'application/javascript',
			'png' 	=> 'image/png',
			'txt' 	=> 'text/plain',
			'xml' 	=> 'text/xml'
		];
	}

	/**
		Read http request
	*/
	public function readRequest( buf : Bytes, pos : Int, len : Int ) : HTTPRequest {
		return HTTPRequest.read( buf, pos, len );
	}

	/**
		Process http request
	*/
	public function processRequest( r : HTTPRequest, ?root : String ) {
		responseCode = { code : 200, text : "OK" };
		responseHeaders = createResponseHeaders();
	}

	function getFileContentType( path : String ) : String {
		var x = Path.extension( path );
		return mime.exists(x) ? mime.get(x) : 'unknown/unknown';
	}

	function createResponseHeaders() : HTTPHeaders {
		var h = new HTTPHeaders();
		#if cpp //TODO  Date.format %A- not implemented yet
		h.set( 'Date', Date.now().toString() );
		#elseif neko
		h.set( 'Date', DateTools.format( Date.now(), '%A, %e %B %Y %I:%M:%S %Z' ) );
		#end
		/*
		if( keepAlive ) {
			h.set( 'Connection', 'Keep-Alive' );
			h.set( 'Keep-Alive', 'timeout=5, max=99' );
		}
		if( compression ) {
			h.set( 'Content-Encoding', 'gzip' );
		}
		*/
		//h.set( 'Server', WebServer.name );
		return h;
	}

	function sendData( data : String ) {
		responseHeaders.set( 'Content-Length', Std.string( data.length ) );
		sendHeaders();
		//TODO buffered send
		output.writeString( data );
	}

	function sendError( code : Int, status : String, ?content : String ) {
		responseCode = { code : code, text : status };
		if( content != null ) responseHeaders.set( 'Content-Length', Std.string( content.length ) );
		sendHeaders();
		if( content != null ) output.writeString( content );
	}

	function sendHeaders() {
		writeLine( 'HTTP/1.1 ${responseCode.code} ${responseCode.text}' );
		for( k in responseHeaders.keys() ) writeLine( '$k: ${responseHeaders.get(k)}' );
		writeLine();
	}

	inline function writeLine( s : String = "" ) output.writeString( '$s\r\n' );

}
