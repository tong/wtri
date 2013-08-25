package sys.net;

import sys.net.Socket;
import haxe.io.Bytes;

//TODO use as base for every server and as 'simple-server'

class SocketServer {
	
	public var host(default,null) : String;
	public var port(default,null) : Int;

	var sock : Socket;

	function new() {
		
	}

	public function start() {
	}

	public dynamic function clientConnected( s : Socket ) : Client {
		return null;
	}

}