
var server : wtri.Server;

private function main() {

    var host = "localhost";
	var port = 8080;
	var root : String = null;

    var uv = true;
    //var maxConnections = 0;

    var usage : String = null;
    var argHandler = hxargs.Args.generate([
        @doc("Address to bind")["-host"] => (name:String) -> host = name,
        @doc("Port number")["-port"] => (number:Int) -> {
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

    var handlers : Array<wtri.Handler> = [
        new wtri.handler.FileSystemHandler( root )
    ];

    Main.server = startServer( host, port, uv, handlers );
}

function startServer( host : String, port : Int, uv = true, handlers : Array<wtri.Handler> ) {
    println('Starting server http://$host:$port' );
    var b = Bytes.ofString( 'Hello!');
    return new wtri.Server( (req,res) -> {
        var handledBy : wtri.Handler = null;
        for( h in handlers ) {
            if( h.handle( req, res ) ) {
                handledBy = h;
                break;
            }
        }
        if( handledBy == null ) {
            res.writeHead( NOT_FOUND ).end();
            //res.error( NOT_FOUND );
        }
        var peer = req.socket.peer();
        log( '${peer.host}:${peer.port} - ${req.method} /${req.path} - ${res.code}' );

    }).listen( port, host, uv );
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
