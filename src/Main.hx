
private function main() {

    var host = "localhost";
	var port = 8080;
	var root : String = null;

    var autoindex = true;
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
        @doc("IP address to bind")["-host"] => (name:String) -> host = name,
        @doc("Port number")["-port"] => (number:Int) -> {
            if( number < 1 || number > 65535 ) exit( 'Invalid port number' );
            port = number;
        },
        @doc("Filesystem root path")["-root"] => (path:String) -> {
            if( !FileSystem.exists( path ) || !FileSystem.isDirectory( path ) )
                exit( 'Root path not found' );
            root = path;
        },
        /* @doc("Use libuv with num connections")["-uv"] => (connections:Int) -> {
            //TODO
        }, */
        @doc("Print this help")["--help"] => () -> exit( usage ),
        _ => arg -> exit( 1, 'Unknown argument\n\n$usage' )
    ]);
    usage = 'Usage: wtri [options]\n\n'+argHandler.getDoc();
    argHandler.parse( Sys.args() );

    if( root == null ) root = Sys.getCwd();

    var server = new wtri.Server( (req,res) -> {
        var path = '$root/'+req.path;
        if( !FileSystem.exists( path )) {
            res.writeHead( NOT_FOUND );
            res.end();
            //log( '${req.host} - ${req.method} ${req.path} ${res.statusCode}' );
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
                //var content = File.getBytes( path );
                res.end();

                /* var fi = File.read( path );
                var pos = 0;
                //res.wre( fi );
                res.write( File.getBytes( path ) );
                res.end(); */

                //res.end( content );
            }
        }
        log( '${req.stream} - ${req.method} /${req.path} - ${res.statusCode}' );
    });
    println('Starting server $host:$port ← $root' );
    server.listen( port, host, true );
}

function log( msg : String ) {
    var time = DateTools.format( Date.now(), '%H:%M:%S' );
    println( '$time - $msg' );
}

function exit( code = 0, ?msg : String ) {
    if( msg != null ) println( msg );
    Sys.exit( code );
}
