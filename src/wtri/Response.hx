package wtri;

class Response {

    public var stream : wtri.Stream;

    public var statusCode : StatusCode = OK;
    public var headers : Map<String,String>;

    public var headersSent(default,null) = false;
    public var finished(default,null) = false;
    //public var writableEnded(default,null) = false;

    public function new( stream : wtri.Stream, ?headers : Map<String,String> ) {
        this.stream = stream;
        this.headers = (headers != null) ? headers : [];
    }
    
    public function writeHead( statusCode : StatusCode, ?statusMessage : String, ?headers : Map<String,String> ) : Response {
        this.statusCode = statusCode;
        var str = 'HTTP/1.1 ${statusCode}';
        if( statusMessage != null ) str += ' ${statusMessage}';
        else str += ' '+StatusMessage.fromStatusCode( statusCode );
        str += '\r\n';
        if( headers != null ) {
            for( k=>v in headers ) this.headers.set( k, v );
        }
        for( k=>v in this.headers ) str += '$k: $v\r\n';
        stream.write( Bytes.ofString( '$str\r\n' ) );
        headersSent = true;
        return this;
    }

    public function write( bytes : Bytes ) {
        stream.write( bytes );
        return this;
    }
    
    public function writeInput( i : haxe.io.Input ) {
        write( i.readAll() );
        return this;
    } 

    public function end( ?data : Bytes ) {
        if( !headersSent ) {
            var headers = new Map<String,String>();
            if( data != null ) {
                headers.set('Content-length', Std.string( data.length ) );
            }
            writeHead( statusCode, headers );
        }
        if( data != null )
            stream.write( data );
        finished = true;
        //stream.close();
        return this;
    }
}