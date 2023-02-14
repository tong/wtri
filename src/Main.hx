
import format.tools.Deflate;

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
    var maxConnections = 20;

    var usage : String = null;
    var argHandler = hxargs.Args.generate([
        @doc("Address to bind")["--host"] => (name:String) -> host = name,
        @doc("Port to bind")["--port"] => (number:Int) -> {
            if( number < 1 || number > 65535 )
                exit( 'Port number out of range' );
            port = number;
        },
        @doc("Filesystem root")["--root"] => (path:String) -> {
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
        _ => arg -> exit( 1, 'Unknown argument [$arg]\n' )
    ]);
    usage = 'Usage: wtri [options]\n\n'+argHandler.getDoc();
    argHandler.parse( Sys.args() );

    if( root == null ) root = Sys.getCwd();

    wtri.Response.defaultHeaders.set( 'server', 'wtri' );
   
    /*
    var wsHandler = new wtri.handler.WebSocketHandler();
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

    var handlers : Array<wtri.Handler> = [
        //wsHandler,
        new wtri.handler.FileSystemHandler( root ),
        //new wtri.handler.ContentEncoding( ["deflate" => b -> return haxe.zip.Compress.run(b,9)] )
        //new wtri.handler.ContentEncoding( ["deflate" => b -> return Deflate.run(b)] )
    ];

    Sys.println('Starting server http://$host:$port' );
    server = new wtri.Server( (req,res) -> {
        //res.end( 'Hello!' );
        /*
        if( req.path == "/favicon.ico" ) {
            res.redirect('/favicon.svg');
        }
        */
        for( h in handlers ) h.handle( req, res );
        if( !res.finished ) res.end();
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
    //Sys.stdout().writeString( Std.int((Sys.time() - startTime) * 1000)  +' $str\n' );
    Sys.stdout().writeString( Date.now().toString()  +' - $str\n' );
}

function exit( code = 0, ?msg : String ) {
    if( msg != null ) {
        if(code == 0) {
            Sys.stdout().writeString( '$msg\n' );
        } else {
            Sys.stderr().writeString( '$msg\n' );
        }
    }
    Sys.exit( code );
}

