package wtri.net;

import haxe.crypto.Base64;
import haxe.crypto.Sha1;
import haxe.io.BytesBuffer;
import haxe.io.Input;
import haxe.io.Output;

class WebSocket {

    public static inline var MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

    public static function createKey( skey : String ) : String {
        return Base64.encode( Sha1.make( Bytes.ofString( '$skey$MAGIC_STRING' ) ) );
    }

    public static function readFrame( i : Input ) : Bytes {
        return switch i.readByte() {
        case 0x00:
            final buf = new BytesBuffer();
            var byte : Int;
            while( (byte = i.readByte()) != 0xFF ) buf.addByte( byte );
            buf.getBytes();
        case 0x81:
            var len = i.readByte();
            if( len & 0x80 != 0 ) { // mask
                len &= 0x7F;
                if( len == 126 ) {
                    final b2 = i.readByte();
                    final b3 = i.readByte();
                    len = (b2 << 8) + b3;
                } else if( len == 127 ) {
                    final b2 = i.readByte();
                    final b3 = i.readByte();
                    final b4 = i.readByte();
                    final b5 = i.readByte();
                    len = ( b2 << 24 ) + ( b3 << 16 ) + ( b4 << 8 ) + b5;
                }
                final mask = [
                    i.readByte(),
                    i.readByte(),
                    i.readByte(),
                    i.readByte() 
                ];
                final buf = new BytesBuffer();
                for( n in 0...len ) buf.addByte( i.readByte() ^ mask[n % 4] );
                buf.getBytes();
            } else null;
        case _: null;
        }
    }

    public static function writeFrame( o : Output, data : Bytes ) {
        o.writeByte( 0x81 );
        var len = if( data.length < 126 ) data.length else if( data.length < 65536 ) 126 else 127;
		o.writeByte( len | 0x00 );
		if( data.length >= 126 ) {
			if( data.length < 65536 ) {
				o.writeByte( (data.length >> 8) & 0xFF );
				o.writeByte( data.length & 0xFF );
			} else {
				o.writeByte( (data.length >> 24) & 0xFF );
				o.writeByte( (data.length >> 16) & 0xFF );
				o.writeByte( (data.length >> 8) & 0xFF );
				o.writeByte( data.length & 0xFF );
			}
		}
		o.write( data );
    }
}
