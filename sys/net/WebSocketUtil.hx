package sys.net;

import haxe.crypto.BaseCode;
import haxe.crypto.Sha1;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Output;

class WebSocketUtil {

	public static inline var MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
	
	/**
	*/
	public static function read( buf : Bytes, pos : Int, len : Int ) : String {
		var i = new BytesInput( buf, pos, len );
		switch( i.readByte() ) {
		case 0x00 :	
			var s = "";
			var b : Int;
			while( ( b = i.readByte() ) != 0xFF )
				s += String.fromCharCode(b);
			return s;
		case 0x81 :
			var len = i.readByte();
			if (len & 0x80 != 0) { // mask
				len &= 0x7F;
				if( len == 126 ) {
					var b2 = i.readByte();
					var b3 = i.readByte();
					len = (b2 << 8) + b3;
				} else if (len == 127) {
					var b2 = i.readByte();
					var b3 = i.readByte();
					var b4 = i.readByte();
					var b5 =i.readByte();
					len = ( b2 << 24 ) + ( b3 << 16 ) + ( b4 << 8 ) + b5;
				}
				var mask = [];
				mask.push( i.readByte() );
				mask.push( i.readByte() );
				mask.push( i.readByte() );
				mask.push(  i.readByte() );
				var data = new StringBuf();
				for( n in 0...len )
					data.addChar( i.readByte() ^ mask[n % 4]);
				return data.toString();
			}
		}
		return null;
	}

	/**
	*/
	public static function write( o : Output, t : String ) {
		o.writeByte( 0x81 );
		var len = if( t.length < 126 ) t.length else if( t.length < 65536 ) 126 else 127;
		o.writeByte( len | 0x00 );
		if( t.length >= 126 ) {
			if( t.length < 65536 ) {
				o.writeByte( ( t.length >> 8 ) & 0xFF );
				o.writeByte( t.length & 0xFF );
			} else {
				o.writeByte( ( t.length >> 24) & 0xFF );
				o.writeByte( ( t.length >> 16) & 0xFF );
				o.writeByte( ( t.length >> 8) & 0xFF );
				o.writeByte( t.length & 0xFF);
			}
		}
		o.writeString( t );
	}

	/**
		Handshake with given input.
		Returns the 
	*/
	public static function handshake( i : BytesInput ) : String {
		var l = i.readLine();
		if( !~/^GET (\/[^\s]*) HTTP\/1\.1$/.match( l ) ) {
			trace( "invalid header" );
			return null;
		}
		var host : String = null;
		var origin : String = null;
		var skey : String = null;
		var sversion : String = null;
		var r = ~/^([a-zA-Z0-9\-]+): (.+)$/;
		while( true ) {
			l = i.readLine();
			if( l == "" ) {
				break;
			}
			if( !r.match( l ) ) {
				return null;
			}
			switch( r.matched(1) ) {
			case "Upgrade" :
			case "Connection" :
			case "Host" : host = r.matched(2);
			case "Origin" : origin = r.matched(2);
			case "Sec-WebSocket-Key" : skey = r.matched(2);
			case "Sec-WebSocket-Version" : sversion = r.matched(2);
			case "Cookie" :
			case "" :
				break;
			}
		}
		var key = encodeBase64( hex2data( Sha1.encode( StringTools.trim( skey ) + MAGIC_STRING ) ) );
		var s = "HTTP/1.1 101 Switching Protocols\r\n"
			  + "Upgrade: websocket\r\n"
			  + "Connection: Upgrade\r\n"
			  + "Sec-WebSocket-Accept: " + key + "\r\n"
			  + "\r\n";
		return s;
	}

	public static function hex2data( hex : String ) : String {
		var t = "";
		for( i in 0...Std.int( hex.length / 2 ) )
			t += String.fromCharCode( Std.parseInt( "0x" + hex.substr( i * 2, 2 ) ) );
		return t;
	}

	public static function encodeBase64( t : String ) : String {
		var suffix = switch( t.length % 3 )  {
			case 2 : "=";
			case 1 : "==";
			default : "";
		};
		return BaseCode.encode( t, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/") + suffix;
	}

}
