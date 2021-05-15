package wtri;

#if hl
typedef Stream = hl.uv.Stream;
#elseif sys

import sys.net.Socket;

class Stream {

    var socket : Socket;

    public function new( socket : Socket ) {
        this.socket = socket;
    }

    public function write( bytes : Bytes ) {
        socket.output.write( bytes );
    }

    public function close() {
        trace("CLOSE");
        socket.close();
    }
}

#end
