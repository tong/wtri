package wtri;

class Server {

    static var EXPR_HTTP = ~/(GET|POST|PUT|HEAD) \/(.*) (HTTP\/1\.(0|1))/;
    static var EXPR_HTTP_HEADER = ~/([a-zA-Z-]+): (.+)/;

    public var name = "wtri";
    public var handler : Request->Response->Void;

    public function new( handler : Request->Response->Void ) {
        this.handler = handler;
    }
    
    public function listen( port : Int, host = 'localhost', uv = false, maxConnections = 20 ) : Server {
        #if hl
        if( uv ) {
            var loop = hl.uv.Loop.getDefault();
            var tcp = new hl.uv.Tcp( loop );
            tcp.bind( new sys.net.Host(host), port );
            tcp.listen( maxConnections, () -> {
                var stream = tcp.accept();
                stream.readStart( bytes -> {
                    if( bytes == null ) {
                        stream.close();
                        return;
                    }
                    processRequest( new wtri.Stream.UVStream( stream ), new BytesInput( bytes ) );
                });
            });
            return this;
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
        return this;
    }

    function processRequest( stream : Dynamic, i : haxe.io.Input ) {
        var line = i.readLine();
        if( !EXPR_HTTP.match( line ) ) {
            println( 'Invalid http: $line' );
            stream.close();
            return;
        }
        final method = EXPR_HTTP.matched(1);
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
        final req = new Request( stream, method, path, params, protocol );
        while( true ) {
            if( (line = i.readLine()).length == 0 )
                break;
            if( !EXPR_HTTP_HEADER.match( line ) ) {
                //TODO
                trace("LINE NOT NMATCHED ",line);
                return;
                //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
            }
            final key = EXPR_HTTP_HEADER.matched(1);
            final val = EXPR_HTTP_HEADER.matched(2);
            req.headers.set( key, val );
        }
        switch req.method {
        case POST, PUT:
            final len = Std.parseInt( req.headers.get( "Content-Length" ) );
            req.data = Bytes.alloc( len );
            i.readBytes( req.data, 0, len );
        case _:
        }
        final res = new Response( stream );
        res.headers.set( 'Server', 'wtri' );
        res.headers.set( 'Date', Date.now().toString() );
        handler( req, res );
        log( '${req.stream} - ${req.method} /${req.path} - ${res.statusCode}' );
    }

    public static function log( obj : Dynamic, time = true ) {
        var str = "";
        if( time ) str += DateTools.format( Date.now(), '%H:%M:%S - ' );
        println( '$str$obj' );
    }

}