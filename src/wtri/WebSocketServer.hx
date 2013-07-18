package wtri;

import sys.WebSocketServerClient;
import sys.net.Socket;

/**
	Development websocket server
*/
@:require(sys)
class WebSocketServer extends sys.WebSocketServer<Client> {

	public static var verbose = true;

	override function clientConnected( s : Socket ) : Client {
		return new Client( s );
	}

	static function main() {

		var args = Sys.args();
		var host = 'localhost';
		var port = 9991;
		if( args[0] != null ) host = args[0];
		if( args[1] != null ) port = Std.parseInt( args[1] );

		var srv = new WebSocketServer( host, port );
		if( verbose ) Sys.println( 'Starting websocket server at $host:$port' );
		try srv.start() catch(e:Dynamic) {
			Sys.println( 'wtri error : $e' );
		}
	}
}

private class Client extends sys.WebSocketServerClient {

	override function handleConnect() {
		trace( "Client connected"  );
	}

	override function processData( data : String ) {
		trace( "Process data : "+data );
		switch( data ) {
		case 'Hello!':
			write( 'Oi!' );
		}
	}

}
