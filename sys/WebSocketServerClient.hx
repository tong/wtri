package sys;

import sys.net.Socket;
import sys.net.WebSocketUtil;
import haxe.io.Bytes;
import haxe.io.BytesInput;

class WebSocketServerClient {

	public var bufSize : Int;

	var socket : Socket;
	var o : haxe.io.Output;
	var handshaked : Bool;

	public function new( socket : Socket, bufSize : Int = 1024 ) {
		this.socket = socket;
		this.bufSize = bufSize;
		o = socket.output;
		handshaked = false;
	}

	/**
		Read client input
	*/
	public function read( buf : Bytes, pos : Int, len : Int ) : Int {
		if( handshaked ) {
			handleData( readWebSocket( buf, pos, len ) );
			return len;
		}
		var r = WebSocketUtil.handshake( new BytesInput( buf, pos, len ) );
		if( r == null ) {
			trace( "handshake failed" );
			socket.close();
			return null;
		}
		o.writeString( r );
		handshaked = true;
		return len;
	}

	function readWebSocket( buf : Bytes, pos : Int, len : Int ) : String {
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

	// override me
	function handleData( data : String ) {
		send( "Hello, i am the wtri websocket server" );
	}

	inline function send( t : String ) {
		WebSocketUtil.send( o, t );
	}
}
