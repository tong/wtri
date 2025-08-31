package wtri.handler;

class FileSystemHandler implements wtri.Handler {
	public var root:String;
	public var mime:Map<String, String>;
	public var indexFileNames:Array<String>;
	public var indexFileTypes:Array<String>;
	public var autoIndex:Bool;

	public function new(root:String, ?mime:Map<String, String>, ?indexFileNames:Array<String>, ?indexFileTypes:Array<String>, ?autoIndex = false) {
		this.root = FileSystem.fullPath(Path.normalize(root));
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
				final data = Bytes.ofString(html);
				res.headers.set(Content_Type, "text/html");
				res.headers.set(Content_Length, Std.string(data.length));
				// res.end(OK, html);
				res.data = data;
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
		final directories:Array<String> = [];
		final files:Array<String> = [];
		for (e in FileSystem.readDirectory(path))
			FileSystem.isDirectory(Path.join([path, e])) ? directories.push(e) : files.push(e);

		function sort(a:String, b:String) {
			a = a.toLowerCase();
			b = b.toLowerCase();
			return a > b ? 1 : a < b ? -1 : 0;
		}
		directories.sort(sort);
		files.sort(sort);

		final html = new StringBuf();
		final title = StringTools.htmlEscape(reqPath);
		html.add('<!DOCTYPE html><html><head><meta charset="utf-8"><title>Index of $title</title></head><body>');
		html.add('<h1>Index of $title</h1>');
		html.add('<hr>');
		html.add('<pre>');
		html.add('<table>');
		html.add('<tr><th align="left">Name</th><th align="left">Last Modified</th><th align="left">Size</th></tr>');
		html.add('<tr><td><a href="../">../</a></td><td></td><td></td></tr>');
		for (dir in directories) {
			try {
				final stat = FileSystem.stat(Path.join([path, dir]));
				final href = Path.normalize(Path.join([reqPath, StringTools.urlEncode(dir)]));
				html.add('<tr>');
				html.add('<td><a href="${href}/">${StringTools.htmlEscape(dir)}/</a></td>');
				html.add('<td>${stat.mtime}</td>');
				html.add('<td>-</td>');
				html.add('</tr>');
			} catch (e:Any) {
				// Could be a permissions error, skip file.
			}
		}
		for (file in files) {
			try {
				final stat = FileSystem.stat(Path.join([path, file]));
				final href = Path.normalize(Path.join([reqPath, StringTools.urlEncode(file)]));
				html.add('<tr>');
				html.add('<td><a href="${href}">${StringTools.htmlEscape(file)}</a></td>');
				html.add('<td>${stat.mtime}</td>');
				html.add('<td>${stat.size}</td>');
				html.add('</tr>');
			} catch (e:Any) {
				// Could be a permissions error, skip file.
			}
		}
		html.add('</table>');
		html.add('</pre>');
		html.add('<hr>');
		html.add('</body>');
		html.add('</html>');
		return html.toString();
	}
}
