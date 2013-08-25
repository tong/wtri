package sys.net;

import sys.net.Socket;

/**
	Base class for socket server clients
*/
class SocketServerClient {

	var socket : Socket;
	var output : haxe.io.Output;

	function new( socket : Socket ) {
		this.socket = socket;
		output = socket.output;
	}

	/*
	public function read( buf : Bytes, pos : Int, len : Int ) : T {
		throw 'SocketServerClient read not implemented';
	}

	public function process<T>( m : T ) {
	}
	*/

	public function cleanup() {
		//socket.close();
	}
	
}
