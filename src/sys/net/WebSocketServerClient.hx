package sys.net;

import sys.net.Socket;
import haxe.io.Bytes;
import haxe.net.WebSocketUtil;

class WebSocketServerClient {

	var socket : Socket;
	var output : haxe.io.Output;

	public function new( socket : Socket ) {
		this.socket = socket;
		output = socket.output;
	}

	/**
		Read incoming data
	*/
	public function readRequest( buf : Bytes, pos : Int, len : Int ) : String {
		return WebSocketUtil.read( buf, pos, len );
	}

	/**
		Process incoming data
	*/
	public function processRequest( r : String ) {
	}

}
