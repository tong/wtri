package wtri.handler;

typedef Encoder = Bytes->Bytes;

class ContentEncoding implements wtri.Handler {

    public var encoders : Map<String,Encoder>;

    public function new( encoders : Map<String,Encoder> ) {
        this.encoders = encoders;
    }

    public function handle( req : Request, res : Response ) : Bool {
        if( res.finished || res.data == null )
            return false;
        var enc = req.getEncoding();
        for( k in encoders.keys() ) {
            if( enc.indexOf( k ) != -1 ) {
                res.data = encoders.get(k)( res.data );
                res.headers.set( Content_Encoding, 'deflate' );
                return true;
            }
        }
        return false;
    }

}
