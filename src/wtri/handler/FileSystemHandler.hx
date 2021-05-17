package wtri.handler;

class FileSystemHandler implements wtri.Handler {

    public var path : String;
    public var mime : Map<String,String>;
    public var indexFileNames = ['index'];
    public var indexFileTypes = ['html','htm'];
    //public var autoindex = false;

    public function new( path : String, ?mime : Map<String,String> ) {
        this.path = FileSystem.fullPath( path.trim() ).removeTrailingSlashes();
        this.mime = (mime != null) ? mime : [
            "css" => TextCss,
            "html" => TextHtml,
            "gif" => ImageGif,
            'jpg' => ImageJpeg,
            "js" => TextJavascript,
            "json" => ApplicationJson,
            'png' => ImagePng,
            'txt' => TextPlain,
            'xml' => ApplicationXml,
            "webp" => ImageWebp,
            "woff" => 'font/woff',
            "woff2" => 'font/woff2',
        ];
    }

    public function handle( req : Request, res : Response ) : Bool {
        var _path = '$path/'+req.path;
        //TODO check path security
        //trace(req.path);
        var filePath = findFile( _path );
        if( filePath == null )
            return false;
        var content = File.getContent( filePath );
        var contentType = getFileContentType( filePath );
        res.writeHead( OK, [
            'Content-type' => contentType,
            'Content-length' => Std.string( content.length )
        ] );
        res.end( Bytes.ofString( content ) );
        return true;
    }

    function findFile( path : String ) : String {
		if( !FileSystem.exists( path ) )
			return null;
		if( FileSystem.isDirectory( path ) )
			return findIndexFile( path );
		return path;
	}

    function findIndexFile( path : String ) : String {
		var r = new EReg( '(${indexFileNames.join("|")}).(${indexFileTypes.join("|")})$', '' );
		for( f in FileSystem.readDirectory( path ) )
			if( r.match( f ) )
				return path +'/'+ r.matched(1) + '.' + r.matched(2);
		return null;
	}

    function getFileContentType( path : String ) : String {
		var x = path.extension();
		return mime.exists(x) ? mime.get(x) : 'unknown/unknown';
	}

}