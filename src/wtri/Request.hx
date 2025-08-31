package wtri;

import wtri.http.HeaderName;
import wtri.http.Headers;
import wtri.http.Method;

/**
	Represents an incoming HTTP/1.1 request.
**/
class Request {
	public static final HTTP_REQUEST = ~/^(GET|POST|PUT|HEAD|DELETE|PATCH|OPTIONS|TRACE|CONNECT) ([^ ]+) (HTTP\/1\.[01])$/i;
	public static final HTTP_HEADER = ~/^([a-zA-Z0-9_-]+): *(.*)$/;

	public final socket:Socket;
	public final input:haxe.io.Input;
	public final protocol:String;
	public final method:Method;
	public final headers:Headers = [];
	public final params:Map<String, String> = [];
	public final data:Bytes;

	public var path:String;

	public function new(socket:Socket, input:haxe.io.Input) {
		this.socket = socket;
		this.input = input;
		final line = input.readLine();
		if (!HTTP_REQUEST.match(line)) {
			throw new Error(BAD_REQUEST, 'Invalid request line: $line');
		}
		method = HTTP_REQUEST.matched(1);
		path = HTTP_REQUEST.matched(2);
		protocol = HTTP_REQUEST.matched(3);
		parsePath();
		parseHeaders();
		data = switch method {
			case POST | PUT | PATCH:
				final contentLength = headers.get(Content_Length);
				if (contentLength == null)
					throw new Error(LENGTH_REQUIRED);
				final len = Std.parseInt(contentLength);
				if (len == null || len < 0)
					throw new Error(BAD_REQUEST, 'Invalid Content-Length: $contentLength');
				len == 0 ? Bytes.alloc(0) : input.readAll(len);
			case _:
				Bytes.alloc(0);
		}
	}

	function parsePath() {
		final pos = path.indexOf('?');
		if (pos != -1) {
			final query = path.substr(pos + 1);
			path = path.substr(0, pos);
			for (p in query.split('&')) {
				final parts = p.split("=");
				final name = StringTools.urlDecode(parts[0]);
				final value = parts.length > 1 ? StringTools.urlDecode(parts[1]) : "";
				params.set(name, value);
			}
		}
		path = StringTools.urlDecode(path);
	}

	function parseHeaders() {
		var line:String;
		while ((line = input.readLine()).length > 0) {
			if (!HTTP_HEADER.match(line))
				throw new Error(BAD_REQUEST, 'Invalid header: $line');
			final key = HTTP_HEADER.matched(1);
			final val = HTTP_HEADER.matched(2);
			headers.set(key, val);
		}
	}

	/**
		Returns an array of accepted encodings from the `Accept-Encoding` header.
		@param header The header to parse. Defaults to `Accept-Encoding`.
		@return An array of accepted encodings.
	**/
	public function getEncoding(header:HeaderName = Accept_Encoding):Array<String>
		return headers.exists(header) ? ~/ ?, ?/g.split(headers.get(header)) : [];

	// public function dispose() {
	//	headers = [];
	//	data = null;
	//	socket.close();
	// }

	public function toString()
		return '$method $path';
}
