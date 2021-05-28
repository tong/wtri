package wtri.net;

interface Socket {
    function write( data : Data ) : Void;
    function writeInput( input : haxe.io.Input, len : Int ) : Void;
    function close() : Void;
}

class TCPSocket implements Socket {

    public var socket(default,null) : sys.net.Socket;

    public inline function new( socket : sys.net.Socket )
        this.socket = socket;

    public inline function write( data : Data )
        socket.output.write( data );

    public inline function writeInput( input : haxe.io.Input, len : Int )
        socket.output.writeInput( input, len );

    public inline function close()
        socket.close();
}

#if hl

class UVSocket implements Socket {

    public var socket(default,null) : hl.uv.Stream;

    public inline function new( socket : hl.uv.Stream )
        this.socket = socket;

    public inline function write( data : Data )
        socket.write( data );

    public inline function writeInput( input : haxe.io.Input, len : Int )
        socket.write( input.readAll() );
       
    public inline function close()
        socket.close();
}

#end
