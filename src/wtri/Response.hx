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
		final chunked = body != null && headers.get(Content_Length) == null;
		if (chunked)
			headers.set(Transfer_Encoding, "chunked");
		if (!headersSent)
			writeHead(this.code);
		if (body != null) {
			if (request.method != HEAD) {
				try {
					if (chunked)
						writeChunked(body);
					else
						request.socket.writeInput(body, Std.parseInt(headers.get(Content_Length)));
				} catch (e) {
					// swallow; the connection is torn down below
				}
			}
			body.close();
		}
		finished = true;
		final connection = headers.get(Connection);
		if (connection == null || connection.toLowerCase() != 'keep-alive')
			request.socket.close();
	}

	public function toString()
		return '${request.method} ${request.path} ${code}';

	inline function writeLine(line:String)
		request.socket.write(Bytes.ofString('$line\r\n'));

	function writeChunked(body:haxe.io.Input) {
		final chunkSize = 65536;
		final buf = Bytes.alloc(chunkSize);
		while (true) {
			var read = 0;
			try {
				read = body.readBytes(buf, 0, chunkSize);
			} catch (e:haxe.io.Eof) {
				break;
			}
			if (read == 0)
				break;
			writeLine(StringTools.hex(read));
			request.socket.write(read == buf.length ? buf : buf.sub(0, read));
			writeLine('');
		}
		writeLine('0');
		writeLine('');
	}
}
