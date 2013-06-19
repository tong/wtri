package haxe;

/**
	Development websocket server
*/
@:require(sys)
class WebSocketServer extends sys.WebSocketServer {

	public static var name = 'Haxe development server';

	static function main() {
		var host = 'localhost';
		var port = 7000;
		var args = Sys.args();
		try {
			if( args[0] != null ) host = args[0];
			if( args[1] != null ) port = Std.parseInt( args[1] );
		} catch(e:Dynamic) {
			Sys.println(e);
			Sys.exit(1);
		}
		var server = new WebSocketServer( host, port );
		Sys.println( 'Starting server $host:$port' );
		try server.start() catch(e:Dynamic) {
			Sys.println(e);
		}
	}
	
}
