
var server(default,null) : wtri.Server;

private function main() {

    var host = "localhost";
	var port = 8080;
	var root : String = null;

    var uv = true;
    var maxConnections = 100;

    var usage : String = null;
    var argHandler = hxargs.Args.generate([
        @doc("Address to bind")["-host"] => (name:String) -> host = name,
        @doc("Port number to bind")["-port"] => (number:Int) -> {
            if( number < 1 || number > 65535 )
                exit( 'Invalid port number' );
            port = number;
        },
        @doc("Filesystem root path")["-path"] => (path:String) -> {
            if( !FileSystem.exists( path ) || !FileSystem.isDirectory( path ) )
                exit( 'Root path not found' );
            root = path;
        },
        //#if hl @doc("Use libuv")["--uv"] => () -> uv = true, #end
        @doc("Print this help")["--help"] => () -> exit( usage ),
        _ => arg -> exit( 1, 'Unknown argument\n\n$usage' )
    ]);
    usage = 'Usage: wtri [options]\n\n'+argHandler.getDoc();
    argHandler.parse( Sys.args() );

    if( root == null ) root = Sys.getCwd();

    wtri.Response.defaultHeaders.set( 'server', 'wtri' );

    var handlers : Array<wtri.Handler> = [
        new wtri.handler.FileSystemHandler( root )
    ];
    
    println('Starting server http://$host:$port' );
    server = new wtri.Server( (req,res) -> {
        /* if( req.path == "/favicon.ico" ) {
            res.redirect('/favicon.svg');
        } */
        if( !res.finished ) {
            var handledBy : wtri.Handler = null;
            for( h in handlers ) {
                if( h.handle( req, res ) ) {
                    handledBy = h;
                    break;
                }
            }
            if( handledBy == null ) {
                res.end( NOT_FOUND );
            }
        }
        var peer = req.socket.peer();
        log( '${peer.host} - ${req.method} ${req.path} - ${res.code}' );
    }).listen( port, host, uv, maxConnections );
}

function log( obj : Dynamic, time = true ) {
    var str = "";
    if( time ) str += DateTools.format( Date.now(), '%H:%M:%S - ' );
    println( '$str$obj' );
}

function exit( code = 0, ?msg : String ) {
    if( msg != null ) println( msg );
    Sys.exit( code );
}
