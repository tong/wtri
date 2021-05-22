package wtri;

class Server {

    public var name = "wtri";
    public var handle : Request->Response->Void;
    
    var listening : Bool;

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
        while( listening )
            process( server.accept() );
        return this;
    }

    public function stop() {
        listening = false;
        return this;
    }

    public function process( socket : Socket ) {
        final req = new Request( socket );
        final res = req.createResponse();
        handle( req, res );
        socket.close();
        /*
        var req : Request = null;
        try {
            req = Request.read( socket.input );
        } catch(e:Error) {
            trace(e);
            socket.close();
            return;
        }
        final res = new Response( socket.output );
        //res.headers.set( 'Server', 'wtri' );
        //res.headers.set( 'Date', Date.now().toString() );
        try {
            handle( req, res );
        } catch(e:Dynamic) {
            trace(e);
            socket.close();
            return;
        }
        */
    }
}