package wtri;

import wtri.http.Headers;
import wtri.http.HeaderName;

class Response {
	public static var defaultHeaders:Headers = [];

	public final request:Request;
	public final protocol:String;

	public var socket(get, never):Socket;
	public var headersSent(default, null) = false;
	public var finished(default, null) = false;

	public var code:StatusCode = OK;
	public var headers:Headers;
	public var data:Bytes;

	public function new(request:Request, ?headers:Headers, protocol = "HTTP/1.1") {
		this.request = request;
		this.headers = headers ?? [];
		this.protocol = protocol;
	}

	inline function get_socket():Socket
		return request.socket;

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

	// public inline function write(data:Bytes) {
	//	socket.write(data);
	// }

	/* public inline function writeInput( input : haxe.io.Input, len : Int ) {
		socket.writeInput( input, len );
	}*/
	public function redirect(path:String) {
		code = MOVED_PERMANENTLY;
		headers.set(Location, path);
		end();
	}

	public function end(?code:StatusCode, ?data:Bytes) {
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
			// if (this.data != null && !this.headers.exists(Content_Length)) {
			//	headers.set(Content_Length, Std.string(this.data.length));
			// }
			// writeHead(this.code);
		}
		if (this.data != null) {
			final input = new haxe.io.BytesInput(this.data);
			socket.writeInput(input, this.data.length);
		}
		finished = true;
		switch headers.get(Connection) {
			case null, 'close':
				socket.close();
		}
	}

	// public function dispose() {
	//	finished = true;
	//	code = null;
	//	headers = [];
	//	data = null;
	//	socket.close();
	// }

	public function toString()
		return '${request.method} ${request.path} ${code}';

	inline function writeLine(line:String)
		socket.write(Bytes.ofString('$line\r\n'));
}
