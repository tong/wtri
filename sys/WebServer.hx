package sys;

import sys.net.Socket;
#if no_threads
import sys.net.SocketServer;
#else
import sys.net.ThreadSocketServer;
#end
import haxe.io.Bytes;

class WebServer extends
	#if no_threads
	//TODO SocketServer<WebServerClient>
	#else
	ThreadSocketServer<WebServerClient,String>
	#end {

	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var path(default,null) : String;

	public function new( host : String, port : Int,
						 path : String ) {

		if( path.charAt( path.length-1 ) != "/" ) path += "/";

		super();
		this.host = host;
		this.port = port;
		this.path = path;
	}

	public function start() {
		try {
			run( host, port );
		} catch( e : Dynamic ) {
			trace(e);
			Sys.exit(1);
		}
	}

	/*
	public function stop() {
		//TODO
		//active = false;
	}
	*/

	public override function clientConnected( s : Socket ) : WebServerClient {
		#if dev_server
		//trace( 'Client connected ['+s.peer()+']' );
		#end
		return new WebServerClient( s, path );
	}

	public override function readClientMessage( c : WebServerClient, buf : Bytes, pos : Int, len : Int ) {
		var len = c.read( buf, pos, len );
		return { msg : null, bytes : len };
	}

	override function clientDisconnected( c : WebServerClient ) {
		#if dev_server
		//trace( "Client disconnected " );
		#end
		//c.close();
 	}

	#if dev_server

	public static function log( v : Dynamic, ?inf : haxe.PosInfos ) {
		var s = new StringBuf();
		var params : Array<Dynamic> = null;
		if( inf != null && inf.customParams != null && inf.customParams.length > 0 ) {
			params = inf.customParams;
			s.add( '[' );
			s.add( params[0] ); // ip
			s.add( ']' );
			s.add( ' - ' );
		}
		s.add( '[' );
		s.add(  Date.now().toString() );
		s.add( ']' );
		s.add( ' - ' );
		s.add( v );
		Sys.println( s.toString() );
	}

	static function main() {

		//haxe.Log.trace = log;
		
		var host = 'localhost';
		var port = 7000;
		var path = Sys.getCwd();

		var args = Sys.args();
		try {
			if( args[0] != null ) host = args[0];
			if( args[1] != null ) port = Std.parseInt( args[1] );
			if( args[2] != null ) path = args[2];
		} catch(e:Dynamic) {
			trace( 'ERROR : '+e );
			Sys.exit(0);
		}
		var server = new WebServer( host, port, path );
		trace( 'Starting development web server : $host:$port:$path' );
		server.start();
	}

	#end
}
