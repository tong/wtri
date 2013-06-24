package wtri;

import sys.FileSystem;
import sys.WebServerClient;
import sys.net.Socket;
import haxe.Resource;
import haxe.Template;
import haxe.io.Bytes;

using Lambda;
using StringTools;

/**
	Development web server
*/
@:require(sys)
class Server extends sys.WebServer<Client> {

	static inline var VERSION = '0.2';
	static var HELP = 'Wtri Development Server $VERSION
  Usage : wtri [host] [port] [path]
    help : Display this list of options';

	public static var name = 'Haxe Development Server';
	//public static var libPrefix = 'wtri---';
	public static var libPath = '/home/tong/disktree/wtri/lib/';
	public static var verbose = true;
	public static var indexTemplate = new Template( Resource.getString("index") );

	override function clientConnected( s : Socket ) : Client {
		return new Client( s, path );
	}

	static inline function exit( ?m: String ) {
		if( m != null ) Sys.println( m );
		Sys.exit(0);
	}

	static function main() {

		var args = Sys.args();
		switch( args[0] ) {
		case 'help':
			exit( HELP );
		}

		var host = 'localhost';
		var port = 9870;
		var path = Sys.getCwd();

		if( args[0] != null ) host = args[0];
		if( args[1] != null ) port = Std.parseInt( args[1] );
		if( args[2] != null ) path = args[2];
	
		var srv = new Server( host, port, path );
		if( verbose ) Sys.println( 'Starting web server $host:$port - $path' );
		try srv.start() catch(e:Dynamic) {
			Sys.println(e);
		}
	}
}

private class Client extends sys.WebServerClient {

	override function processRequest( r : HTTPClientRequest, ?customRoot : String ) {
		
		//trace( "---------------------- processRequest "+r.url  );

		/*
		if( r.url.startsWith( Server.libPrefix ) ) {
			customRoot = Server.libPath;
			r.url = r.url.substr( Server.libPrefix.length );
		}
		*/

		super.processRequest( r, customRoot );

		if( Server.verbose ) {
			var s = new StringBuf();
			s.add( socket.peer().host );
			s.add( ' - ' );
			var now = Date.now();
			var time = DateTools.format( Date.now(), '%d/%b/%Y:%H:%M:%S %z' );
			s.add( time );
			s.add( ' - ' );
			s.add( if( r.method == null ) 'GET' else Std.string( r.method ).toUpperCase() );
			s.add( ' - ' );
			s.add( '"'+(if( r.url == null || r.url.length == 0 ) '/' else r.url)+'"' );
			//TODO
		//	if( r.params.array().count() > 0 ) r.params.array().join('/');
			s.add( ' - ' );
			s.add( r.headers.get('User-Agent') );
			Sys.println( s.toString() );
		}
	}

	override function fileNotFound( path : String, url : String ) {
		if( !FileSystem.exists( path ) || !FileSystem.isDirectory( path ) ) {
			super.fileNotFound( path, url );
			return;
		}
		var dirs = [], files = [];
		for( f in FileSystem.readDirectory( path ) ) {
			var p = path+f;
			var fstat = FileSystem.stat( p );
			var now = Date.now();
			var mtime = fstat.mtime;
			var modified = '';
			if( now.getFullYear() != mtime.getFullYear() ) modified += mtime.getFullYear()+'-';
			modified += DateTools.format( mtime, '%d-%B %H:%M:%S' );
			var o : Dynamic = {
				name : f,
				path : f,
				modified : modified
			};
			if( FileSystem.isDirectory( p ) ) {
				o.icon = '/wtri/lib/icons/folder.png'; //Server.libPrefix+'icons/folder.png'; //TODO
				dirs.push( o );
			} else {
				var icon = 'mime-unknown';
				if( !f.startsWith('.') ) {
					switch(f) {
					case 'README', 'README.md' : icon = 'mime-readme';
					case 'CHANGES' : icon = 'mime-changelog';
					case 'Makefile' : icon = 'mime-make';
					default:
						var i = f.indexOf('.');
						if( i != -1 ) {
							var ext = f.substr( i+1 ).toLowerCase();
							icon = 'mime-'+getMimeIconName( ext );
						}
					}
				}
				o.icon = '/wtri/lib/icons/$icon.png'; //TODO
				o.size = fstat.size;
				files.push( o );
			}
		}
		dirs.sort( sortByName );
		files.sort( sortByName );
		var host = socket.host();
		var ctx = {
			path : url,
			parent : '../',
			dirs : dirs,
			files : files, 
			address : Server.name+' '+host.host+':'+host.port,
		};
		sendData( Server.indexTemplate.execute( ctx ) );
	}

	override function createResponseHeaders() : Headers {
		var h = super.createResponseHeaders();
		h.set( 'Server', Server.name );
		return h;
	}

	static function sortByName( a : { name : String }, b : { name : String } ) : Int {
		var a = a.name.toLowerCase();
   		var b = b.name.toLowerCase();
   		return if( a < b ) -1 else if( a > b ) 1 else 0;
	}

	static function getMimeIconName( ext : String ) : String {
		return switch( ext ) {
		case 'ant': 'xml';
		case 'avi': 'video';
		case 'cc': 'cpp';
		case 'gz': 'zip';
		case 'htm': 'html';
		case 'jpeg': 'jpg';
		case 'mk': 'make';
		case 'mpg','mp3': 'mpeg';
		case 'sublime-project', 'sublime-workspace': 'sublime-text';
		case 'tiff': 'tif';
		case 'ttf','otf': 'font';
		default: 'unknown';
		}
	}
}
