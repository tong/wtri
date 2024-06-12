package wtri.handler;

class FileSystemHandler implements wtri.Handler {
	public var path:String;
	public var mime:Map<String, String>;
	public var indexFileNames:Array<String>;
	public var indexFileTypes:Array<String>;
	public var autoIndex:Bool;

	public function new(path:String, ?mime:Map<String, String>, ?indexFileNames:Array<String>, ?indexFileTypes:Array<String>, ?autoIndex = false) {
		this.path = FileSystem.fullPath(path.trim()).removeTrailingSlashes();
		this.mime = mime ?? [
			"css" => TextCss, "gif" => ImageGif, "html" => TextHtml, "ico" => "image/x-icon", "jpg" => ImageJpeg, "jpeg" => ImageJpeg, "js" => TextJavascript,
			"json" => ApplicationJson, "png" => ImagePng, "svg" => "image/svg+xml", "txt" => TextPlain, "wasm" => "application/wasm", "webp" => ImageWebp,
			"woff" => "font/woff", "woff2" => "font/woff2", "xml" => ApplicationXml,
		];
		this.indexFileNames = indexFileNames ?? ["index"];
		this.indexFileTypes = indexFileTypes ?? ["html", "htm"];
		this.autoIndex = autoIndex;
	}

	public function handle(req:Request, res:Response):Bool {
		final _path = resolvePath(req.path);
		// TODO: check path security
		final filePath = findFile(_path);
		if (filePath == null) {
			if (autoIndex) {
				if (FileSystem.isDirectory(_path)) {
					var html = createAutoIndex(_path, req.path);
					res.headers.set(Content_Type, "text/html");
					res.headers.set(Content_Length, Std.string(html.length));
					res.data = html;
				} else {
					res.code = NOT_FOUND;
				}
			} else {
				res.code = NOT_FOUND;
			}
			return true;
		}
		res.headers.set(Content_Type, getFileContentType(filePath));
		res.data = File.getBytes(filePath);
		/*
			var enc = req.getEncoding();
			if( enc.indexOf( 'deflate' ) != -1 ) {
				data = Deflate.run( data );
				res.headers.set( Content_Encoding, 'deflate' );
		}*/
		// res.end( data );
		/*
			final stat = FileSystem.stat( filePath );
			res.writeHead( [
				'Content-type' => contentType,
				'Content-length' => Std.string( data.length )
				//'Content-length' => Std.string( stat.size )
			] ); */
		// res.writeInput( File.read( filePath ), stat.size );
		// res.write(data);
		return true;
	}

	function resolvePath(path:String):String {
		return '${this.path}${path}'.normalize();
	}

	function findFile(path:String):String {
		if (!FileSystem.exists(path))
			return null;
		if (FileSystem.isDirectory(path))
			return findIndexFile(path);
		return path;
	}

	function findIndexFile(path:String):String {
		final r = new EReg('^(${indexFileNames.join("|")})\\.(${indexFileTypes.join("|")})$', '');
		for (f in FileSystem.readDirectory(path)) {
			final p = '$path/$f';
			if (!FileSystem.isDirectory(p) && r.match(f)) {
				return p;
			}
		}
		return null;
	}

	function getFileContentType(path:String):String {
		final x = path.extension().toLowerCase();
		return mime.exists(x) ? mime.get(x) : 'unknown/unknown';
	}

	function createAutoIndex(path:String, reqPath:String):String {
		final entries = FileSystem.readDirectory(path);
		final directories = new Array<String>();
		final files = new Array<String>();
		var html = '<html><title>Index of $reqPath</title><body><pre><table>';
		for (e in entries)
			FileSystem.isDirectory('$path/$e') ? directories.push(e) : files.push(e);
		function sort(a:String, b:String)
			return (a > b) ? 1 : (a < b) ? -1 : 0;
		directories.sort(sort);
		files.sort(sort);
		for (e in directories) {
			final lp = reqPath.removeTrailingSlashes() + '/' + e;
			final stat = FileSystem.stat('$path/$e');
			html += '<tr><td><a href="$lp/">$e</a></td><td>${stat.mtime}</td><td>-</td></tr>';
		}
		for (e in files) {
			final lp = reqPath.removeTrailingSlashes() + '/' + e;
			final stat = FileSystem.stat('$path/$e');
			html += '<tr><td><a href="$lp">$e</a></td><td>${stat.mtime}</td><td>-</td><td>${stat.size}</td></tr>';
		}
		return html + '</pre></table></body></html>';
	}
}
