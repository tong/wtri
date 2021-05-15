package wtri;
/* 
#if hl
typedef Stream = hl.uv.Stream;

#elseif sys */

import sys.net.Socket;

class Stream {

    public final socket : Socket;

    public inline function new( socket : Socket ) {
        this.socket = socket;
    }

    public inline function write( bytes : Bytes ) {
        socket.output.write( bytes );
    }

    public inline function close() {
        socket.close();
    }
}

// #end
