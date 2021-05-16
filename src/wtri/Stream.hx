package wtri;

interface Stream {
    function write( bytes : Bytes ) : Void;
    function close() : Void;
}

class SocketStream implements Stream {

    public var socket(default,null) : sys.net.Socket;

    public inline function new( socket : sys.net.Socket ) {
        this.socket = socket;
    }

    public inline function write( bytes : Bytes ) {
        socket.output.write( bytes );
    }

    public inline function close() {
        socket.close();
    }
}

#if hl

class UVStream implements Stream {

    public var stream(default,null) : hl.uv.Stream;

    public inline function new( stream : hl.uv.Stream ) {
        this.stream = stream;
    }

    public inline function write( bytes : Bytes ) {
        stream.write( bytes );
    }

    public inline function close() {
        stream.close();
    }
}

#end
