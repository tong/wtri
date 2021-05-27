package wtri;

class Server {

    public var listening(default,null) = false;
    public var handle : Request->Response->Void;

    public function new( handle : Request->Response->Void ) {
        this.handle = handle;
    }
    
    public function listen( port : Int, host = 'localhost', uv = false, maxConnections = 100 ) : Server {
      /*   #if hl
        if( uv ) {
            var loop = hl.uv.Loop.getDefault();
            var tcp = new hl.uv.Tcp( loop );
            tcp.bind( new sys.net.Host(host), port );
            tcp.listen( maxConnections, () -> {
                var stream = tcp.accept();
                trace(stream);
                stream.readStart( bytes -> {
                    trace(bytes);
                    process( new wtri.UVStream( stream ), new BytesInput( bytes ) );
                });
            });
            return this;
        }
        #end */
        var server = new Socket();
        server.bind( new sys.net.Host( host ), port );
        server.listen( maxConnections );
        listening = true;
        while( listening ) {
            try {
                process( server.accept() );
            } catch(e) {
                trace(e);
            }
        }
        server.close();
        return this;
    }

    public function stop() : Server {
        listening = false;
        return this;
    }

    public function process( socket : Socket ) {
        final req = new Request( socket );
        final res = req.createResponse();
        handle( req, res );
        socket.close();
    }
}