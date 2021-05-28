package wtri;

class Server {

    public var listening(default,null) = false;
    public var handle : Request->Response->Void;

    public function new( handle : Request->Response->Void ) {
        this.handle = handle;
    }
    
    public function listen( port : Int, host = 'localhost', uv = false, maxConnections = 100 ) : Server {
        #if hl
        if( uv ) {
            var loop = hl.uv.Loop.getDefault();
            var tcp = new hl.uv.Tcp( loop );
            tcp.bind( new sys.net.Host(host), port );
            tcp.listen( maxConnections, () -> {
                var s = tcp.accept();
                s.readStart( bytes -> {
                    var sock = new wtri.net.Socket.UVSocket(s);
                    inline process( sock, new BytesInput( bytes ) );
                    sock.close();
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
        return this;
    }

    public function stop() : Server {
        listening = false;
        return this;
    }

    public function process( socket : Socket, ?input : haxe.io.Input ) {
        final req = new Request( socket, input );
        final res = req.createResponse();
        handle( req, res );
    }
}