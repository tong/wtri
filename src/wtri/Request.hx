package wtri;

class Request {

    static var EXPR_HTTP = ~/(GET|POST|PUT|HEAD) \/(.*) (HTTP\/1\.(0|1))/;
    static var EXPR_HTTP_HEADER = ~/([a-zA-Z-]+): (.+)/;

    public final socket : Socket;

    public final method : Method;
    public final path : String;
    public final params : Map<String,String>;
    public final protocol : String;
    public final headers = new Map<String,String>();

    public var data : Bytes;

    public function new( socket : Socket ) {
        this.socket = socket;
        final i = socket.input;
        var line = i.readLine();
        if( !EXPR_HTTP.match( line ) )
            return throw new Error( BAD_REQUEST );
        method = EXPR_HTTP.matched(1);
        path = EXPR_HTTP.matched(2);
        protocol = EXPR_HTTP.matched(3);
        params = new Map<String,String>();
        var pos = path.indexOf( '?' );
        if( pos != -1 ) {
            var s = path.substr( pos+1 );
            path = path.substr( 0, pos );
            for( p in s.split('&') ) {
                var a = p.split( "=" );
                params.set( a[0], a[1] );
            }
        }
        while( true ) {
            if( (line = i.readLine()).length == 0 )
                break;
            if( !EXPR_HTTP_HEADER.match( line ) ) {
                //TODO
                trace("LINE NOT NMATCHED ",line);
                return throw new Error( BAD_REQUEST );
                //return throw new HTTPError( HTTPStatusCode.BAD_REQUEST );
            }
            final key = EXPR_HTTP_HEADER.matched(1);
            final val = EXPR_HTTP_HEADER.matched(2);
            headers.set( key, val );
        }
        switch method {
        case POST, PUT:
            final _len = headers.get( "Content-Length" );
            if( _len == null )
                return throw new Error( BAD_REQUEST );
            final len = Std.parseInt( headers.get( "Content-Length" ) );
            i.readBytes( data = Bytes.alloc( len ), 0, len );
        case _:
        }
    }

    public function createResponse() : Response {
        final res = new Response( socket );
        //res.req = this;
        return res;
    }
}
