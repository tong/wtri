package wtri.http;

//TODO
// class Error extends #if js js.lib.Error #end {
class Error {

    public final code : StatusCode;
    public final message : StatusMessage;

    public function new( code : StatusCode, ?message : StatusMessage ) {
        this.code = code;
        this.message = (message == null) ? StatusMessage.fromStatusCode( code ) : message;
    }
}