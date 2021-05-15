package wtri;

class Request {

    public var method : String;
    public var path : String;
    public var headers = new Map<String,String>();

    var stream : Stream;

    public function new( stream : Stream, method : Method, path : String ) {
        this.stream = stream;
        this.method = method;
        this.path = path;
    }
}