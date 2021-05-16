
private function main() {

    var host = "localhost";
	var port = 8080;
	var root : String = null;

    var useUV = false;
    //var maxConnections = 0;
    //var autoindex = true;

    var mime = [
        "html" => TextHtml,
        "js" => TextJavascript,
        "css" => TextCss,
        "json" => ApplicationJson,
        "woff" => 'font/woff',
        "woff2" => 'font/woff2',
    ];
    
    var usage : String = null;
    var argHandler = hxargs.Args.generate([
        @doc("Address to bind")["-host"] => (name:String) -> host = name,
        @doc("Port number")["-port"] => (number:Int) -> {
            if( number < 1 || number > 65535 ) exit( 'Invalid port number' );
            port = number;
        },
        @doc("Filesystem root path")["-root"] => (path:String) -> {
            if( !FileSystem.exists( path ) || !FileSystem.isDirectory( path ) )
                exit( 'Root path not found' );
            root = path;
        },
        #if hl
        @doc("Use libuv")["--uv"] => () -> useUV = true,
        #end
        @doc("Print this help")["--help"] => () -> exit( usage ),
        _ => arg -> exit( 1, 'Unknown argument\n\n$usage' )
    ]);
    usage = 'Usage: wtri [options]\n\n'+argHandler.getDoc();
    argHandler.parse( Sys.args() );

    if( root == null ) root = Sys.getCwd();

    startServer( host, port, root, mime, useUV );
}

function startServer( host : String, port : Int, root : String, mime : Map<String,String>, useUV : Bool ) {
    var server = new wtri.Server( (req,res) -> {
        var path = '$root/'+req.path;
        if( !FileSystem.exists( path )) {
            res.writeHead( NOT_FOUND );
            res.end();
        } else {
            if( FileSystem.isDirectory( path ) ) {
                var ipath = '$path/index.html';
                if( !FileSystem.exists( ipath ) ) {
                    res.writeHead( NOT_FOUND ).end();
                } else {
                    var content = File.getContent( ipath );
                    res.writeHead( OK, [
                        'Content-type' => TextHtml,
                        'Content-length' => Std.string( content.length )
                    ] );
                    res.end( Bytes.ofString( content ) );
                }
            } else {
                var stat = FileSystem.stat( path );
                var ext = path.extension();
                var type = mime.get( ext );
                res.writeHead( OK, [
                    'Content-type' => type,
                    'Content-length' => Std.string( stat.size )
                ] );
                res.writeInput( File.read( path ) );
                res.end();
            }
        }
        log( '${req.stream} - ${req.method} /${req.path} - ${res.statusCode}' );
    });
    println('Starting server http://$host:$port → $root' );
    server.listen( port, host, useUV );
}

function log( msg : String ) {
    var time = DateTools.format( Date.now(), '%H:%M:%S' );
    println( '$time - $msg' );
}

function exit( code = 0, ?msg : String ) {
    if( msg != null ) println( msg );
    Sys.exit( code );
}
