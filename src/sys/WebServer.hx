package sys;

import haxe.io.Bytes;
import sys.net.Socket;
import sys.net.ThreadSocketServer;

class WebServer<Client:WebServerClient> extends ThreadSocketServer<Client,String> {

	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var path(default,null) : String;

	public function new( host : String, port : Int,
						 ?path : String ) {

		if( path == null ) path = Sys.getCwd();
		if( !StringTools.endsWith( path, "/" ) ) path += "/";
		if( !FileSystem.exists( path ) ) throw 'Root path not found';
		if( !FileSystem.isDirectory( path ) ) throw 'Root path must be a directory';

		super();
		this.host = host;
		this.port = port;
		this.path = path;
	}

	public function start() {
		//active = true;
		run( host, port );
	}

	//TODO
	public function stop() {
		throw 'stop thread server not implemented';
	}

	override function clientConnected( s : Socket ) : Client {
		return throw 'abstract method';
	}

	override function clientDisconnected( c : Client ) {
		c.cleanup();
 	}

	override function readClientMessage( c : Client, buf : Bytes, pos : Int, len : Int ) : { data : String, length : Int } {
		var r = c.readRequest( buf, pos, len );
		if( r == null ) {
			//TODO hmmmm
			return null;
		}
		c.processRequest( r );
		return { data : null, length : len };
	}

}
