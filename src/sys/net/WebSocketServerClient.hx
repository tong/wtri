package sys.net;

import sys.net.Socket;
import haxe.io.Bytes;
import haxe.net.WebSocketUtil;

class WebSocketServerClient {

	var socket : Socket;
	var output : haxe.io.Output;
	var handshaked : Bool;

	public function new( socket : Socket ) {
		this.socket = socket;
		output = socket.output;
		handshaked = false;
	}

	/**
		Read incoming data
	*/
	public function readRequest( buf : Bytes, pos : Int, len : Int ) : String {
		trace("readRequest");
		if( !handshaked ) {
			var r = WebSocketUtil.handshake( new haxe.io.BytesInput( buf ) );
			if( r == null ) {
				trace('handshake failed');
				return null; //TODO
			}
			socket.write( r );
			handshaked = true;
			return null;
		} else {
			return WebSocketUtil.read( buf, pos, len );
		}
	}

	/**
		Process incoming data
	*/
	public function processRequest( r : String ) {
		/*
		trace(r);
		if( !handshaked ) {
			var input = new haxe.io.BytesInput( Bytes.ofString(r) );
			var r = WebSocketUtil.handshake( input );
			socket.write(r);
			handshaked = true;
			return;
		}
		*/
	}
}
