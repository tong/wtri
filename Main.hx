
import sys.FileSystem;
import wtri.net.Socket;

var server(default,null) : wtri.Server;
var startTime = Sys.time();

private function main() {

    var host = "localhost";
	var port = 8080;
	var root : String = null;

    var quiet = false;
    var uv = false;
    var maxConnections = 100;

    var usage : String = null;
    var argHandler = hxargs.Args.generate([
        @doc("Address to bind")["-host"] => (name:String) -> host = name,
        @doc("Port to bind")["-port"] => (number:Int) -> {
            if( number < 1 || number > 65535 )
                exit( 'Invalid port number' );
            port = number;
        },
        @doc("Filesystem root")["-path"] => (path:String) -> {
            if( !FileSystem.exists( path ) || !FileSystem.isDirectory( path ) )
                exit( 'Root path not found' );
            root = path;
        },
        #if hl
        @doc("Use libuv")["--uv"] => (connections:Int) -> {
            maxConnections = connections;
            uv = true;
        },
        #end
        @doc("Disable logging to stdout")["--quiet"] => () -> quiet = true,
        @doc("Print this help")["--help"] => () -> exit( usage ),
        _ => arg -> exit( 1, 'Unknown argument [$arg]\n\n$usage' )
    ]);
    usage = 'Usage: wtri [options]\n\n'+argHandler.getDoc();
    argHandler.parse( Sys.args() );

    if( root == null ) root = Sys.getCwd();

    //wtri.Response.defaultHeaders.set( 'server', 'wtri' );
    
    /* var wsHandler = new WebSocketHandler();
    wsHandler.onconnect = client -> {
        trace("Websocket client connected",wsHandler.clients.length, client.socket.peer().host );
        client.onmessage = m -> {
            trace("Websocket client message: "+m);
            if( m != null ) {
                var str = m.toString();
                switch str {
                case 'quit':
                    client.close();
                case _:
                    wsHandler.broadcast( m );
                }
            }
        }
        client.ondisconnect = () -> {
            trace("Websocket client disconnected",wsHandler.clients.length);
        }
        client.write("Welcome!");
    }
 */
    var fsHandler = new wtri.handler.FileSystemHandler( root );
    //fsHandler.cache.file('/84.jpg');
    //fsHandler.cacheFile('/diamond.json');
    //fsHandler.cacheFile('/app.js');
    //fsHandler.cacheFile('/script/three.js');

    var handlers : Array<wtri.Handler> = [
        //wsHandler,
        fsHandler
    ];

    Sys.println('Starting server http://$host:$port' );
    server = new wtri.Server( (req,res) -> {
        /* if( req.path == "/favicon.ico" ) {
            res.redirect('/favicon.svg');
        } */
        //res.end( 'Hello!' );
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
        if( !quiet ) {
            if( Std.isOfType( req.socket, TCPSocket ) ) {
                var tcp : wtri.net.Socket.TCPSocket = cast req.socket;
                var peer = tcp.socket.peer();
                log( '${peer.host} - ${req.method} ${req.path} - ${res.code}' );
            } else {
                log( '${req.method} ${req.path} - ${res.code}' );
            }
        }
    }).listen( port, host, uv, maxConnections );
}

function log( str : String ) {
    Sys.stdout().writeString( Std.int((Sys.time() - startTime) * 1000)  +' $str\n' );
}

function exit( code = 0, ?msg : String ) {
    if( msg != null ) Sys.stdout().writeString( '$msg\n' );
    Sys.exit( code );
}
