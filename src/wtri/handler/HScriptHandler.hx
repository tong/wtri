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
		this.root = FileSystem.fullPath(Path.normalize(root));
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
			if (res.finished)
				return true;
			res.code = FORBIDDEN;
			res.end();
			return true;
		}

		if (!FileSystem.exists(scriptPath) || FileSystem.isDirectory(scriptPath))
			return false;

		var result:Dynamic = null;
		try {
			result = executeScript(scriptPath, req, res);
		} catch (e:hscript.Expr.Error) {
			if (res.finished)
				return true;
			res.code = INTERNAL_SERVER_ERROR;
			if (debug) {
				var msg = getScriptErrorMessage(e);
				final bodyBytes = Bytes.ofString(msg);
				res.headers.set(Content_Length, Std.string(bodyBytes.length));
				res.body = new haxe.io.BytesInput(bodyBytes);
			}
			res.end();
			return true;
		} catch (e:haxe.Exception) {
			if (res.finished)
				return true;
			res.code = INTERNAL_SERVER_ERROR;
			var msg = debug ? haxe.CallStack.toString(haxe.CallStack.exceptionStack()).trim() : e.toString();
			if (msg == null) // ISSUE: null on jvm
				msg = "hscript interp error";
			final bodyBytes = Bytes.ofString(msg);
			res.headers.set(Content_Length, Std.string(bodyBytes.length));
			res.body = new haxe.io.BytesInput(bodyBytes);
			res.end();
			return true;
		}

		if (res.finished)
			return true;

		res.code = OK;
		final bodyBytes = (result == null) ? Bytes.ofString("") : Bytes.ofString(Std.string(result));
		final mime = interp.variables.exists("mime") ? interp.variables.get("mime") : this.mime;
		res.headers.set(Content_Type, mime);
		res.headers.set(Content_Length, Std.string(bodyBytes.length));
		res.body = new haxe.io.BytesInput(bodyBytes);
		res.end();

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

	function getScriptErrorMessage(err:hscript.Expr.Error) {
		#if hscriptPos
		return '${err.line}:${err.pmin}-${err.pmax}: ' + switch err.e {
			case EInvalidChar(c): "Invalid character: '" + (StringTools.isEof(c) ? "EOF" : String.fromCharCode(c)) + "' (" + c + ")";
			case EUnexpected(s): "Unexpected token: \"" + s + "\"";
			case EUnterminatedString: "Unterminated string";
			case EUnterminatedComment: "Unterminated comment";
			case EInvalidPreprocessor(str): "Invalid preprocessor (" + str + ")";
			case EUnknownVariable(v): "Unknown variable: " + v;
			case EInvalidIterator(v): "Invalid iterator: " + v;
			case EInvalidOp(op): "Invalid operator: " + op;
			case EInvalidAccess(f): "Invalid access to field " + f;
			case ECustom(msg): msg;
		};
		#else
		return hscript.Printer.errorToString(err);
		#end
	}
}
