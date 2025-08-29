package wtri.handler;

class FileSystemHandler implements wtri.Handler {
	public var root:String;
	public var mime:Map<String, String>;
	public var indexFileNames:Array<String>;
	public var indexFileTypes:Array<String>;
	public var autoIndex:Bool;

	public function new(root:String, ?mime:Map<String, String>, ?indexFileNames:Array<String>, ?indexFileTypes:Array<String>, ?autoIndex = false) {
		this.root = FileSystem.fullPath(root.trim()).removeTrailingSlashes();
		this.mime = mime ?? [
			"css" => TextCss,
			"gif" => ImageGif,
			"html" => TextHtml,
			"ico" => "image/x-icon",
			"jpg" => ImageJpeg,
			"jpeg" => ImageJpeg,
			"js" => TextJavascript,
			"json" => ApplicationJson,
			"mp4" => "video/mp4",
			"png" => ImagePng,
			"svg" => "image/svg+xml",
			"txt" => TextPlain,
			"wasm" => "application/wasm",
			"webp" => ImageWebp,
			"woff" => "font/woff",
			"woff2" => "font/woff2",
			"xml" => ApplicationXml,
		];
		this.indexFileNames = indexFileNames ?? ["index"];
		this.indexFileTypes = indexFileTypes ?? ["html", "htm"];
		this.autoIndex = autoIndex;
	}

	public function handle(req:Request, res:Response):Bool {
		final path = resolvePath(req.path);
		if (!path.startsWith(root)) {
			// res.writeHead(FORBIDDEN);
			res.code = FORBIDDEN;
			res.data = Bytes.ofString(FORBIDDEN);
			// res.end(Bytes.ofString("403 Forbidden"));
			return true;
		}
		final filePath = findFile(path);
		if (filePath == null) {
			if (autoIndex && FileSystem.isDirectory(path)) {
				final html = createAutoIndex(path, req.path);
				res.headers.set(Content_Type, "text/html");
				res.headers.set(Content_Length, Std.string(html.length));
				// res.end(OK, html);
				res.data = html;
			} else {
				// res.end(NOT_FOUND, Bytes.ofString(NOT_FOUND));
				res.code = NOT_FOUND;
				res.data = Bytes.ofString(NOT_FOUND);
			}
			return true;
		}
		res.headers.set(Content_Type, getFileContentType(filePath));
		res.data = File.getBytes(filePath);
		return true;
	}

	function resolvePath(path:String):String
		return Path.join([root, path]).normalize();

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
			final p = Path.join([path, f]);
			if (!FileSystem.isDirectory(p) && r.match(f))
				return p;
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
		for (e in entries)
			FileSystem.isDirectory('$path/$e') ? directories.push(e) : files.push(e);
		function sort(a:String, b:String)
			return a > b ? 1 : a < b ? -1 : 0;
		directories.sort(sort);
		files.sort(sort);
		final html = new StringBuf();
		html.add("<html><title>Index of ");
		html.add(reqPath);
		html.add("</title><body><pre><table>");
		for (e in directories) {
			final lp = Path.join([reqPath, e]);
			final stat = FileSystem.stat('$path/$e');
			html.add('<tr><td><a href="');
			html.add(lp);
			html.add('/">');
			html.add(e);
			html.add("</a></td><td>");
			html.add(stat.mtime);
			html.add("</td><td>-</td></tr>");
		}
		for (e in files) {
			final lp = Path.join([reqPath, e]);
			final stat = FileSystem.stat('$path/$e');
			html.add('<tr><td><a href="');
			html.add(lp);
			html.add('/">');
			html.add(e);
			html.add("</a></td><td>");
			html.add(stat.mtime);
			html.add("</td><td>-</td><td>");
			html.add(stat.size);
			html.add("</td></tr>");
		}
		html.add("</pre></table></body></html>");
		return html.toString();
	}
}
