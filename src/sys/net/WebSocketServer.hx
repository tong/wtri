package sys.net;

import haxe.io.Bytes;
import haxe.net.HTTPError;
import haxe.net.HTTPRequest;

class WebSocketServer<Client:WebSocketServerClient> extends ThreadSocketServer<Client,String> {

	override function clientMessage( c : Client, s : String ) {
		if( s != null )
			c.processRequest( s );
	}

	override function readClientMessage( c : Client, buf : Bytes, pos : Int, len : Int ) : { msg : String, len : Int } {
		var r : String = null;
		try r = c.readRequest( buf, pos, len ) catch(e:Dynamic) {
			trace(e);
			return { msg : null, len : len };
		}
		return { msg : r, len : len };
	}

}
