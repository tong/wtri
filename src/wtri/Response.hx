package wtri;

import wtri.http.Headers;
import wtri.http.HeaderName;

class Response {
	public static var defaultHeaders:Headers = [];

	public final request:Request;
	public final protocol:String;

	public var code:StatusCode = OK;
	public var headers:Headers;
	public var headersSent(default, null) = false;
	public var finished(default, null) = false;
	public var data:Data;

	public var socket(get, never):Socket;

	inline function get_socket():Socket
		return request.socket;

	public function new(request:Request, ?headers:Map<String, String>, protocol = "HTTP/1.1") {
		this.request = request;
		this.protocol = protocol;
		this.headers = (headers != null) ? headers : [];
	}

	public function writeHead(?code:StatusCode, ?extraHeaders:Headers) {
		if (code != null)
			this.code = code;
		writeLine('${protocol} ${this.code} ' + StatusMessage.fromStatusCode(this.code));
		if (extraHeaders != null)
			for (k => v in extraHeaders)
				this.headers.set(k, v);
		for (k => v in Response.defaultHeaders)
			if (!this.headers.exists(k))
				this.headers.set(k, v);
		for (k => v in this.headers)
			writeLine('$k: $v');
		writeLine('');
		headersSent = true;
	}

	public inline function write(data:Data) {
		socket.write(data);
	}

	/* public inline function writeInput( input : haxe.io.Input, len : Int ) {
		socket.writeInput( input, len );
	}*/
	public function redirect(path:String) {
		code = MOVED_PERMANENTLY;
		headers.set(Location, path);
		end();
	}

	public function end(?code:StatusCode, ?data:Data) {
		if (finished)
			return;
		if (code != null)
			this.code = code;
		if (data != null)
			this.data = data;
		if (!headersSent) {
			var extraHeaders = new Map<String, String>();
			if (this.data != null && !this.headers.exists(Content_Length)) {
				extraHeaders.set(Content_Length, Std.string(this.data.length));
			}
			writeHead(this.code, extraHeaders);
		}
		if (this.data != null)
			socket.write(this.data);
		finished = true;
	}

	inline function writeLine(line:Data) {
		socket.write('$line\r\n');
	}
}
