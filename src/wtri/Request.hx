package wtri;

class Request {

    public var stream : wtri.Stream;

    public final method : String;
    public final path : String;
    public final protocol : String;
    public final headers = new Map<String,String>();

    //public maxHeadersCount = 2000;

    public function new( stream : wtri.Stream, method : Method, path : String, protocol : String ) {
        this.stream = stream;
        this.method = method;
        this.path = path;
        this.protocol = protocol;
    }
}