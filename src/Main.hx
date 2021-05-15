
import haxe.Json;

function main() {

    var host = "localhost";
	var port = 8080;
	var root = '/home/tong/dev/web/laerm/web';
    
    var args = Sys.args();
    if( args[0] != null ) host = args[0];
    if( args[1] != null ) port = Std.parseInt( args[1] );
    if( args[2] != null ) root = args[2];

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
    // Sys.println("["+Time.now()+"] "+msg);
    Sys.println( '[${Time.now()}] $msg' );
}
