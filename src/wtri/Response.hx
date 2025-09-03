package wtri;

import wtri.http.Headers;

class Response {
	public static var defaultHeaders:Headers = [];

	public final request:Request;
	public final protocol:String;

	public var headersSent(default, null) = false;
	public var finished(default, null) = false;

	public var code:StatusCode = OK;
	public var headers:Headers;
	public var body:haxe.io.Input;

	public function new(request:Request, ?headers:Headers, protocol = "HTTP/1.1") {
		this.request = request;
		this.headers = headers ?? [];
		this.protocol = protocol;
	}

	public function writeHead(?code:StatusCode, ?extraHeaders:Headers) {
		if (finished || headersSent)
			return;
		if (code != null)
			this.code = code;
		writeLine('${protocol} ${this.code} ${StatusMessage.fromStatusCode(this.code)}');
		for (k => v in Response.defaultHeaders)
			this.headers.set(k, v);
		if (extraHeaders != null)
			for (k => v in extraHeaders)
				this.headers.set(k, v);
		for (k => v in this.headers)
			writeLine('$k: $v');
		writeLine('');
		headersSent = true;
	}

	public function redirect(path:String) {
		code = MOVED_PERMANENTLY;
		headers.set(Location, path);
		end();
	}

	public function end(?code:StatusCode) {
		if (finished)
			return;
		if (code != null)
			this.code = code;
		if (!headersSent)
			writeHead(this.code);
		if (body != null) {
			final contentLength = headers.get(Content_Length);
			if (contentLength == null) {
				// or we could use chunked encoding
				throw "Content-Length header must be set before calling end()";
			}
			try {
				request.socket.writeInput(body, Std.parseInt(contentLength));
			} catch (e) {
				body.close();
			}
		}
		finished = true;
		switch headers.get(Connection) {
			case null, 'close':
				request.socket.close();
		}
	}

	public function toString()
		return '${request.method} ${request.path} ${code}';

	inline function writeLine(line:String)
		request.socket.write(Bytes.ofString('$line\r\n'));
}
