package wtri;

class Server {

    public var name = "wtri";
    public var cors : String; // = "*";

    var handler : Request->Response->Void;

    public function new( handler : Request->Response->Void ) {
        this.handler = handler;
    }

    /* function handleInput( input : haxe.io.Input ) {
        var line = input.readLine();
        trace(line);
        var exp = ~/(GET|POST|HEAD) \/(.*) HTTP\/(1\.(0|1))/;
    } */
    
    #if (hl)

    public function listen( port : Int, host = 'localhost', numConnections = 10 ) {
        var loop = hl.uv.Loop.getDefault();
        var tcp = new hl.uv.Tcp( loop );
        tcp.bind( new sys.net.Host(host), port );
        tcp.listen( numConnections, () -> {
            trace( "Client connected" );
            var stream = tcp.accept();
            stream.readStart( bytes -> {
                if( bytes == null ) {
                    stream.close();
                    return;
                }
                var i = new BytesInput( bytes );
		        var line : String = i.readLine();
                var exp = ~/(GET|POST|HEAD) \/(.*) HTTP\/(1\.(0|1))/;
                if( !exp.match( line ) ) {
                    trace("NOT MATCHED",line);
                    //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
                }
                // trace(exp.matched(1));
                // trace(exp.matched(2));
                // trace(exp.matched(3));
                var req = new Request( stream, exp.matched(1), exp.matched(2) );
                var expr = ~/([a-zA-Z-]+): (.+)/;
                var data : String = null;
                while( true ) {
                    line = i.readLine();
                    if( line.length == 0 ) {
                        if( req.method == POST )
                            data = i.readLine(); 
                        break;
                    }
                    if( !expr.match( line ) ) {
                        trace("LINE NOT NMATCHED ",line);
                        return;
                        //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
                    }
                    req.headers.set( expr.matched(1), expr.matched(2) );
                }
                var res = new Response( stream );
                //if( name != null ) res.headers.set( 'Server', name );
                res.headers.set( 'Server', name );
                res.headers.set( 'Date', Date.now().toString() );
                res.headers.set( 'Content-type', 'unknown/unknown' );
                //if( cors != null ) res.headers.set( 'Access-Control-Allow-Origin', cors );
                handler( req, res );
            });
        });
    }

    #else

    public function listen( port : Int, host = 'localhost' ) {
        var server = new sys.net.Socket();
        server.bind(new sys.net.Host( host ), port );
        server.listen(1);
        while( true ) {
            var c : sys.net.Socket = server.accept();
            trace("Client connected...");
            //handleInput( c.input );
            var i = c.input;
            var line = i.readLine();
            var exp = ~/(GET|POST|HEAD) \/(.*) HTTP\/(1\.(0|1))/;
            if( !exp.match( line ) ) {
                trace("NOT MATCHED",line);
                //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
            }
            // trace(exp.matched(1));
            // trace(exp.matched(2));
            // trace(exp.matched(3));
            var stream = new Stream( c );
            var req = new Request( stream, exp.matched(1), exp.matched(2) );
            var expr = ~/([a-zA-Z-]+): (.+)/;
            var data : String = null;
            while( true ) {
                line = i.readLine();
                if( line.length == 0 ) {
                    if( req.method == POST )
                        data = i.readLine(); 
                    break;
                }
                if( !expr.match( line ) ) {
                    trace("LINE NOT NMATCHED ",line);
                    return;
                    //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
                }
                req.headers.set( expr.matched(1), expr.matched(2) );
            }
            var res = new Response( stream );
            res.headers.set( 'Server', 'wtri' );
            res.headers.set( 'Date', Date.now().toString() );
            //res.headers.set( 'Content-type', 'unknown/unknown' );
            if( cors != null ) {
                res.headers.set( 'Access-Control-Allow-Origin', cors );
            }
            handler( req, res );

            /*
            c.write("hello\n");
            c.write("your IP is "+c.peer().host.toString()+"\n");
            c.write("exit");
            c.close();
            */
        }
    }

    #end

}