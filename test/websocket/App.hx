
import sys.net.Socket;

class Client extends sys.net.WebSocketServerClient {

	public override function processRequest( r : String ) {
		trace( "PROCESS INCOMING DATA: "+r );
		haxe.net.WebSocketUtil.write( output, "Hellooo" );
	}
}

class App extends sys.net.WebSocketServer<Client> {

	public override function clientConnected( s : Socket ) : Client {
		return new Client( s );
	}

	static function main() {
		var server = new App( 'localhost', 2000 );
		server.start();
	}
}