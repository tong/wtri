package haxe.net;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class HTTPRequest {
	
	public var url : String;
	public var version : String;
	public var headers : Map<String,String>;
	public var method : HTTPMethod;
	//res : String,
	//public var ?contentType : String,
	public var params : Map<String,String>;
	public var data : String; // post data

	public function new( url : String, version : String ) {
		this.url = url;
		this.version = version;
		headers = new Map();
		params = new Map();
	}

	public static function read( buf : Bytes, pos : Int, len : Int ) : HTTPRequest {

		var i = new BytesInput( buf, pos, len );
		var line = i.readLine();
		var rexp = ~/(GET|POST) \/(.*) HTTP\/(1\.1)/;
		if( !rexp.match( line ) ) {
			return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
		}

		var url = rexp.matched(2); //TODO check url, security!
		var version = rexp.matched(3);

		var r = new HTTPRequest( url, version );
		var _method = rexp.matched(1);
		r.method = switch( _method ) {
		case 'POST': post;
		case 'GET': get;
		default:
			trace( "TODO handle http method : "+_method );
			null;
		}

		var data : String = null;
		var headerLineExpression = ~/([a-zA-Z-]+): (.+)/;
		while( true ) {
			line = i.readLine();
			/*
			if( line == 'Upgrade: websocket' ) {
				if( !websocketReady ) {
					var res = sys.net.WebSocketUtil.handshake( i );
					if( res != null ) {
						websocketReady = true;
						out.writeString( res );
					}
				}
			}
			*/
			if( line.length == 0 ) {
				if( r.method == post )
					data = i.readLine(); 
				break;
			}
			if( !headerLineExpression.match( line ) ) {
				return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
			}
			r.headers.set( headerLineExpression.matched(1), headerLineExpression.matched(2) );
		}

		var i = r.url.indexOf( '?' );
		if( i != -1 ) {
			//r.params = new HTTPParams();
			var s = url.substr( i+1 );
			r.url = r.url.substr( 0, i );
			for( p in s.split('&') ) {
				var parts = p.split( "=" );
				r.params.set( parts[0], parts[1] );
			}
		}

		return r;
	}

}
