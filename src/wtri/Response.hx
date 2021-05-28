package wtri;

import wtri.http.HeaderName;

class Response {

    public static var defaultHeaders : wtri.http.Headers = [];

    public final socket : Socket;
    public final protocol : String;

    public var code : StatusCode = OK;
    public var headers : wtri.http.Headers;
    public var headersSent(default,null) = false;
    public var finished(default,null) = false;

    public function new( socket : Socket, ?headers : Map<String,String>, protocol = "HTTP/1.1" ) {
        this.socket = socket;
        this.protocol = protocol;
        this.headers = (headers != null) ? headers : [];
    }
    
    public function writeHead( ?code : StatusCode = OK, ?headers : Map<String,String> ) {
        if( code != null ) this.code = code;
        writeLine( '${protocol} ${this.code} '+StatusMessage.fromStatusCode( this.code ) );
        if( headers != null ) for( k=>v in headers ) this.headers.set( k, v );
        for( k=>v in Response.defaultHeaders ) if( !this.headers.exists(k) ) this.headers.set( k, v );
        for( k=>v in this.headers ) writeLine( '$k: $v' );
        writeLine( '' );
        headersSent = true;
    }
    
    public inline function writeInput( input : haxe.io.Input, len : Int ) {
        socket.writeInput( input, len );
    } 
 
    public inline function write( data : Data ) {
        socket.write( data );
    }

    public function redirect( path : String ) {
        code = MOVED_PERMANENTLY;
        headers.set( Location, path );
        end();
    }

    public function end( ?code : StatusCode = OK, ?data : Data ) {
        if( code != null ) this.code = code;
        if( !headersSent ) {
            var headers = new Map<String,String>();
            if( data != null ) {
                headers.set( Content_Length, Std.string( data.length ) );
            }
            writeHead( code, headers );
        }
        if( data != null ) socket.write( data );
        finished = true;
    }

    inline function writeLine( str : String ) {
        socket.write( '$str\r\n' );
    }

}