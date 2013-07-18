package sys;

import sys.net.Socket;
import sys.net.WebSocketUtil;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Output;

class WebSocketServerClient {

	public var handshaked(default,null) : Bool;
	//public var bufSize : Int;

	var socket : Socket;
	var out : Output;

	//public function new( socket : Socket, bufSize : Int = 1024 ) {
	public function new( socket : Socket ) {
		this.socket = socket;
		//this.bufSize = bufSize;
		handshaked = false;
		out = socket.output;
	}

	/**
		Read client input
	*/
	public function readData( buf : Bytes, pos : Int, len : Int ) : String {
		if( handshaked )
			return WebSocketUtil.read( buf, pos, len );
		var r = WebSocketUtil.handshake( new BytesInput( buf, pos, len ) );
		if( r == null ) {
			trace( "websocket handshake failed" );
			try socket.close() catch(e:Dynamic) { trace(e); }
			return null;
		}
		out.writeString( r );
		handshaked = true;
		return "handshaked";
	}

	/**
	*/
	public function handleConnect() {
		// abstract, override me
	}

	/**
		Process client input
	*/
	public function processData( data : String ) {
		//trace("processData "+data );
	}

	/**
	*/
	public function cleanup() {
		//socket.close();
	}

	/**
	*/
	public function write( t : String ) {
		WebSocketUtil.write( out, t );
	}

}
