package sys;

import sys.net.Socket;
import haxe.io.Bytes;

@:require(sys)
class WebSocketServer<Client:WebSocketServerClient> extends sys.net.ThreadSocketServer<Client,String> {

	public var host(default,null) : String;
	public var port(default,null) : Int;

	public function new( host : String, port : Int ) {
		super();
		this.host = host;
		this.port = port;
	}

	public function start() {
		run( host, port );
	}

	public function stop() {
		throw 'stop thread server not implemented'; //TODO
	}

	override function clientConnected( s : Socket ) : Client {
		return throw 'abstract method';
	}

	override function clientDisconnected( c : Client ) {
		c.cleanup();
	}

	override function readClientMessage( c : WebSocketServerClient, buf : Bytes, pos : Int, len : Int ) : { data : String, length : Int } {
		var r = c.readData( buf, pos, len );
		switch(r) {
		case 'handshaked':
			c.handleConnect();
			return { data : null, length : len };
		 case x if(x == null):
			return null;
		}
		c.processData( r );
		return { data : null, length : len };
	}
	
}
