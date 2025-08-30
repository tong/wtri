package wtri;

import wtri.http.HeaderName;
import wtri.http.Headers;
import wtri.http.Method;

/**
	Represents an incoming HTTP/1.1 request.
**/
class Request {
	static final EXPR_HTTP = ~/^(GET|POST|PUT|HEAD|DELETE|PATCH|OPTIONS|TRACE|CONNECT) ([^ ]+) (HTTP\/1\.[01])$/i;
	static final EXPR_HTTP_HEADER = ~/^([a-zA-Z0-9_-]+): *(.*)$/;

	/** The underlying socket for this request. */
	public final socket:Socket;

	/** The input stream to read from. */
	public final input:haxe.io.Input;

	/** The HTTP method of the request (e.g., GET, POST). */
	public final method:Method;

	/** The path of the request, without the query string. */
	public var path:String;

	/** The HTTP protocol version (e.g., "HTTP/1.1"). */
	public final protocol:String;

	/** A map of the query string parameters. */
	public final params = new Map<String, String>();

	/** The headers of the request. */
	public final headers = new Headers();

	/** The body of the request. */
	public final data:Bytes;

	public function new(socket:Socket, input:haxe.io.Input) {
		this.socket = socket;
		this.input = input;

		final line = input.readLine();
		if (!EXPR_HTTP.match(line)) {
			throw new Error(BAD_REQUEST, 'Invalid request line: $line');
		}

		method = EXPR_HTTP.matched(1);
		path = EXPR_HTTP.matched(2);
		protocol = EXPR_HTTP.matched(3);

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
			final queryString = path.substr(pos + 1);
			path = path.substr(0, pos);
			for (p in queryString.split('&')) {
				final parts = p.split("=");
				final name = StringTools.urlDecode(parts[0]);
				final value = (parts.length > 1) ? StringTools.urlDecode(parts[1]) : "";
				params.set(name, value);
			}
		}
	}

	function parseHeaders() {
		var line:String;
		while ((line = input.readLine()).length > 0) {
			if (!EXPR_HTTP_HEADER.match(line))
				throw new Error(BAD_REQUEST, 'Invalid header: $line');
			final key = EXPR_HTTP_HEADER.matched(1);
			final val = EXPR_HTTP_HEADER.matched(2);
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

	public function toString()
		return '$method $path';
}
