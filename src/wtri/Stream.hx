package wtri;

interface Stream {
    final ip : String;
    final port : Int;
    function write( bytes : Bytes ) : Void;
    function close() : Void;
}

class SocketStream implements Stream {

    public var socket(default,null) : sys.net.Socket;

    public final ip : String;
    public final port : Int;

    public inline function new( socket : sys.net.Socket ) {
        this.socket = socket;
        var peer = socket.peer();
        this.ip = peer.host.toString();
        this.port = peer.port;
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

    public final ip : String;
    public final port : Int;

    public inline function new( stream : hl.uv.Stream ) {
        this.stream = stream;
        ip = 'TODO'; //TODO
        port = 1234; //TODO
    }

    public inline function write( bytes : Bytes ) {
        stream.write( bytes );
    }

    public inline function close() {
        stream.close();
    }
}

#end
