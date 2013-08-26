package sys.net;

import haxe.io.Bytes;
import haxe.net.HTTPRequest;
import haxe.net.HTTPError;

/**
	Base class for web servers
*/
@:require(sys)
class WebServer<Client:WebServerClient> extends
	#if (php||wtri_no_threads)  sys.net.SocketServer<Client,HTTPRequest>
	#elseif (cpp||neko) sys.net.ThreadSocketServer<Client,HTTPRequest>
	#end {

	override function clientMessage( c : Client, m : HTTPRequest ) {
		c.processRequest( m );
	}

	override function readClientMessage( c : Client, buf : Bytes, pos : Int, len : Int ) : { msg : HTTPRequest, len : Int } {
		var r : HTTPRequest = null;
		try r = c.readRequest( buf, pos, len ) catch(e:HTTPError) {
			trace(e);
		} catch(e:String) {
			trace(e);
			return { msg : null, len : len };
		}
		return { msg : r, len : len };
	}

}
