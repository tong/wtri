package wtri;

class Server {

    static var EXPR_HTTP = ~/(GET|POST|HEAD) \/(.*) (HTTP\/1\.(0|1))/;
    static var EXPR_HTTP_HEADER = ~/([a-zA-Z-]+): (.+)/;

    public var handler : Request->Response->Void;
    
    public var name = "wtri";
    //public var cors : String; // = "*";

    public function new( handler : Request->Response->Void ) {
        this.handler = handler;
    }
    
    public function listen( port : Int, host = 'localhost', uv = true, maxConnections = 200 ) {
        #if hl
        if( uv ) {
            var loop = hl.uv.Loop.getDefault();
            var tcp = new hl.uv.Tcp( loop );
            tcp.bind( new sys.net.Host(host), port );
            tcp.listen( maxConnections, () -> {
                trace( "Client connected" );
                var stream = tcp.accept();
                stream.readStart( bytes -> {
                    if( bytes == null ) {
                        stream.close();
                        return;
                    }
                    processRequest( new wtri.Stream.UVStream( stream ), new BytesInput( bytes ) );
                });
            });
            return;
        }
        #end
        var server = new sys.net.Socket();
        server.bind( new sys.net.Host( host ), port );
        server.listen( maxConnections );
        while( true ) {
            var socket : sys.net.Socket = server.accept();
            //var peer = socket.peer();
            //trace( "Socket connected "+peer.host );
            processRequest( new wtri.Stream.SocketStream( socket ), socket.input );
        }
    }

    function processRequest( stream : Dynamic, i : haxe.io.Input ) {
        var line : String = i.readLine();
        if( !EXPR_HTTP.match( line ) ) {
            trace( 'Invalid http: $line' );
            stream.close();
            return;
        }
        var method = EXPR_HTTP.matched(1);
        var path = EXPR_HTTP.matched(2);
        var protocol = EXPR_HTTP.matched(3);
        var params = new Map<String,String>();
        var pos = path.indexOf( '?' );
        if( pos != -1 ) {
            var s = path.substr( pos+1 );
            path = path.substr( 0, pos );
            for( p in s.split('&') ) {
                var a = p.split( "=" );
                params.set( a[0], a[1] );
            }
        }
        //trace(path,params);
        //var url = om.URL.parse(path);
        var req = new Request( stream, method, path, protocol );
        var data : String = null;
        while( true ) {
            line = i.readLine();
            if( line.length == 0 ) {
                if( req.method == POST )
                    data = i.readLine(); 
                break;
            }
            if( !EXPR_HTTP_HEADER.match( line ) ) {
                trace("LINE NOT NMATCHED ",line);
                return;
                //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
            }
            req.headers.set( EXPR_HTTP_HEADER.matched(1), EXPR_HTTP_HEADER.matched(2) );
        }
        var res = new Response( stream );
        res.headers.set( 'Server', 'wtri' );
        res.headers.set( 'Date', Date.now().toString() );
        //res.headers.set( 'Content-type', 'unknown/unknown' );
        /*  if( cors != null ) {
            res.headers.set( 'Access-Control-Allow-Origin', cors );
        } */
        handler( req, res );
    }

}
