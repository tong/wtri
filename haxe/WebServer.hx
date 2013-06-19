package haxe;

import sys.FileSystem;
import haxe.Template;

private class Client extends sys.WebServerClient {

	public var showFileIndex : Bool = true;

	override function fileNotFound( path : String ) {
		if( showFileIndex ) {
			var html = new haxe.Template( '<html><body>'+FileSystem.readDirectory( this.path ).join('<br>')+'</body></html>' ).execute( {} );
			sendData( html );
			return;
		} else {
			//TODO custom 404 page
		}
		super.fileNotFound( path );
	}
}

/**
	Development web server
*/
@:require(sys)
class WebServer extends sys.WebServer<Client> {

	public static var name = 'Haxe development server';

	override function clientConnected( s : sys.net.Socket ) : Client {
		trace( 'client connected' );
		return new Client( s, path );
	}

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
