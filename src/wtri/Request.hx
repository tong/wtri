package wtri;

import wtri.http.HeaderName;

class Request {

    static var EXPR_HTTP = ~/^(GET|POST|PUT|HEAD) (.*) (HTTP\/1\.(0|1))$/;
    static var EXPR_HTTP_HEADER = ~/^([a-zA-Z-]+) *: *(.+)$/;

    public final socket : Socket;

    public final method : Method;
    public final path : String;
    public final protocol : String;
    public final params : Map<String,String>;
    public final headers = new wtri.http.Headers();
    public final data : Data;
    
    public function new( socket : Socket, input : haxe.io.Input ) {
        this.socket = socket;
        var line = input.readLine();
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
        var key : String, val : String;
        while( true ) {
            if( (line = input.readLine()).length == 0 )
                break;
            if( !EXPR_HTTP_HEADER.match( line ) )
                return throw new Error( BAD_REQUEST );
            key = EXPR_HTTP_HEADER.matched(1);
            val = EXPR_HTTP_HEADER.matched(2);
            headers.set( key, val );
        }
        switch method {
        case POST, PUT:
            final _len = headers.get( Content_Length );
            if( _len == null )
                return throw new Error( BAD_REQUEST );
            final len = Std.parseInt( headers.get( Content_Length ) );
            input.readBytes( data = Bytes.alloc( len ), 0, len );
        case _:
        }
    }

    public function getEncoding( header : HeaderName = Accept_Encoding ) : Array<String> {
        return headers.exists( header ) ? ~/ ?, ?/g.split( headers.get( header ) ) : [];
    }

    public function createResponse() : Response {
        final res = new Response( this );
        if( headers.get( Connection ) == 'keep-alive' ) {
            res.headers.set( Connection, 'close' );
        }
        return res;
    }
}
