package wtri;

interface Handler {
    function handle( req : Request, res : Response ) : Bool;
}