package wtri.handler;

@:require(hscript)
class HScriptHandler implements wtri.Handler {
	public var root:String;
	public var mime:Mime = TextPlain;
	public var extension = 'hscript';

	public var parser = new hscript.Parser();
	public var interp = new hscript.Interp();
	public var debug:Bool;

	public function new(root:String, debug = true) {
		this.root = root.removeTrailingSlashes();
		this.debug = debug;
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;
	}

	public function handle(req:Request, res:Response):Bool {
		if (Path.extension(req.path) != extension)
			return false;
		final scriptPath = Path.normalize(Path.join([root, req.path]));
		if (!FileSystem.exists(scriptPath) || FileSystem.isDirectory(scriptPath))
			return false;
		var result:Dynamic = null;
		try {
			result = executeScript(scriptPath, req, res);
		} catch (e) {
			if (debug) {
				trace(e);
				if (!res.finished)
					res.end(INTERNAL_SERVER_ERROR, Bytes.ofString(Std.string(e)));
			} else {
				if (!res.finished)
					res.end(INTERNAL_SERVER_ERROR);
			}
			return true;
		}
		if (!res.finished) {
			final body = (result == null) ? Bytes.ofString("") : Bytes.ofString(Std.string(result));
			final mime = interp.variables.exists("mime") ? interp.variables.get("mime") : mime;
			res.writeHead(OK, ['Content-Type' => mime, 'Content-Length' => '${body.length}']);
			res.end(body);
		}
		return true;
	}

	function executeScript(path:String, req:Request, res:Response) {
		final ast = parser.parseString(File.getContent(path));
		interp.variables.set("req", req);
		interp.variables.set("res", res);
		return interp.execute(ast);
	}
}
