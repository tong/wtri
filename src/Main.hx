
function main() {

    var host = "localhost";
	var port = 8080;
	var root : String = null;
    
    var usage : String = null;
    var argHandler = hxargs.Args.generate([
        @doc("IP address to bind")
        ["-host"] => (name:String) -> {
            host = name;
        },
        @doc("Port number")
        ["-port"] => (number:Int) -> {
            if( number < 1 ) exit( 'Invalid port number' );
            if( number > 65535 ) exit( 'Invalid port number' );
            port = number;
        },
        @doc("Root path")
        ["-root"] => (path:String) -> {
            if( !FileSystem.exists( path ) ) exit( 'Root path not found' );
            if( !FileSystem.isDirectory( path ) ) exit( 'Rooth path is a file' );
            root = path;
        },
        @doc("Print this help")
        ["--help"] => () -> {
            exit( 0, usage );
        },
        _ => (arg:String) -> exit( 1, 'Unknown argument' )
    ]);
    usage = argHandler.getDoc();
    var args = Sys.args();
    argHandler.parse(args);

    if( root == null ) root = Sys.getCwd();

    var mime = [
        "html" => TextHtml,
        "js" => TextJavascript,
        "css" => TextCss,
        "json" => ApplicationJson,
        "woff" => 'font/woff',
        "woff2" => 'font/woff2',
    ];

    Sys.println('Starting server $host:$port ← $root' );

    var server = new wtri.Server( (req,res) -> {
        log( '${req.method} ${req.path}' );
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
                //var content = File.getBytes( path );
                //res.end( content );

                /* var fi = File.read( path );
                var pos = 0;
                //res.wre( fi );
                res.write( File.getBytes( path ) );
                res.end(); */

                //res.end( content );
            }
        }
    });
    server.listen( port, host );
}

inline function log( msg : String ) {
    Sys.println( '[${Time.now()}] $msg' );
}

inline function exit( code = 0, ?msg : String ) {
    if( msg != null ) Sys.println( msg );
    Sys.exit( code );
}
