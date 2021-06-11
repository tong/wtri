package wtri;

class Server {

    public var listening(default,null) = false;
    public var handle : Request->Response->Void;

    #if (hl&&libuv)
    var loop : hl.uv.Loop;
    #end

    public function new( handle : Request->Response->Void ) {
        this.handle = handle;
    }
    
    public function listen( port : Int, host = 'localhost', uv = false, maxConnections = 100 ) : Server {
        #if sys
        #if (hl&&libuv)
        if( uv ) {
            loop = hl.uv.Loop.getDefault();
            var tcp = new hl.uv.Tcp( loop );
            tcp.bind( new sys.net.Host(host), port );
            tcp.listen( maxConnections, () -> {
                var s = tcp.accept();
                s.readStart( bytes -> {
                    inline process( new wtri.net.Socket.UVSocket(s), new BytesInput( bytes ) );
                });
            });
            return this;
        }
        #end
        var server = new sys.net.Socket();
        server.bind( new sys.net.Host( host ), port );
        server.listen( maxConnections );
        listening = true;
        while( listening ) {
            var sock = server.accept();
            inline process( new wtri.net.Socket.TCPSocket( sock ), sock.input  );
        }
        server.close();
        #end
        return this;
    }

    public function stop() : Server {
        listening = false;
        #if (hl&&libuv)
        loop.stop()
        #end
        return this;
    }

    public function process( socket : Socket, ?input : haxe.io.Input ) {
        final req = new Request( socket, input );
        final res = req.createResponse();
        handle( req, res );
        switch res.headers.get( Connection ) {
        case null,'close': socket.close();
        }
    }
}