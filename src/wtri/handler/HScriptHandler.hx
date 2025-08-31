package wtri.handler;

private typedef Cache = {
	ast:hscript.Expr,
	mtime:Date
}

@:require(hscript)
class HScriptHandler implements wtri.Handler {
	public var root:String;
	public var extension:String;
	public var mime:Mime;
	public var parser:hscript.Parser;
	public var interp:hscript.Interp;
	public var debug:Bool;
	public var cache:Map<String, Cache> = [];

	public function new(root:String, extension = "hscript", mime = TextPlain, debug = true) {
		// this.root = FileSystem.fullPath(root.trim()).removeTrailingSlashes();
		this.root = Path.normalize(root).removeTrailingSlashes();
		this.extension = extension;
		this.mime = mime;
		this.debug = debug;
		parser = initParser();
		interp = initInterp();
	}

	public function handle(req:Request, res:Response):Bool {
		if (Path.extension(req.path) != extension)
			return false;

		final scriptPath = Path.normalize(Path.join([root, req.path]));
		// Prevent path traversal attacks
		if (!scriptPath.startsWith(root)) {
			if (!res.finished)
				res.end(FORBIDDEN);
			return true;
		}

		if (!FileSystem.exists(scriptPath) || FileSystem.isDirectory(scriptPath))
			return false;

		var result:Dynamic = null;
		try {
			result = executeScript(scriptPath, req, res);
		} catch (e:hscript.Expr.Error) {
			if (debug) {
				// trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
				if (!res.finished) {
					var msg = hscript.Printer.errorToString(e);
					res.end(INTERNAL_SERVER_ERROR, Bytes.ofString(msg));
				}
			} else {
				if (!res.finished)
					res.end(INTERNAL_SERVER_ERROR);
			}
			return true;
		} catch (e) {
			var msg = debug ? haxe.CallStack.toString(haxe.CallStack.exceptionStack()).trim() : e.toString();
			if (msg == null) // ISSUE: null on jvm
				msg = "hscript interp error";
			if (debug)
				trace(msg);
			if (!res.finished) {
				res.end(INTERNAL_SERVER_ERROR, Bytes.ofString(msg));
			}
		}
		if (!res.finished) {
			final body = (result == null) ? Bytes.ofString("") : Bytes.ofString(Std.string(result));
			final mime = interp.variables.exists("mime") ? interp.variables.get("mime") : this.mime;
			res.writeHead(OK, ['Content-Type' => mime, 'Content-Length' => '${body.length}']);
			res.end(body);
		}
		return true;
	}

	function initParser():hscript.Parser {
		final parser = new hscript.Parser();
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;
		return parser;
	}

	function initInterp():hscript.Interp {
		final interp = new hscript.Interp();
		interp.variables.set("Bytes", Bytes);
		interp.variables.set("Date", Date);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("Math", Math);
		return interp;
	}

	// Cache parsed AST to avoid re-parsing on every request
	function getAst(path:String):hscript.Expr {
		final mtime = FileSystem.stat(path).mtime;
		final cached = cache.get(path);
		if (cached != null && cached.mtime.getTime() == mtime.getTime())
			return cached.ast;
		final ast = parser.parseString(File.getContent(path));
		cache.set(path, {ast: ast, mtime: mtime});
		return ast;
	}

	function executeScript(path:String, req:Request, res:Response) {
		final ast = getAst(path);
		interp.variables.set("req", req);
		interp.variables.set("res", res);
		return interp.execute(ast);
	}
}
