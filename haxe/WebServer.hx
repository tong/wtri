package haxe;

/**
	Development web server
*/
@:require(sys)
class WebServer extends sys.WebServer {

	public static var name = 'Haxe development server';

	static function main() {
		var host = 'localhost';
		var port = 9870;
		var path = Sys.getCwd();
		var args = Sys.args();
		try {
			if( args[0] != null ) host = args[0];
			if( args[1] != null ) port = Std.parseInt( args[1] );
			if( args[2] != null ) path = args[2];
		} catch(e:Dynamic) {
			Sys.println(e);
			Sys.exit(1);
		}
		var server = new WebServer( host, port, path );
		Sys.println( 'Starting web server $host:$port - $path' );
		try server.start() catch(e:Dynamic) {
			Sys.println(e);
		}
	}
	
}
