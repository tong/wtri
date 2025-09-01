package wtri.http;

/**
	Represents the status message component of an HTTP response.
	It is typically a short, human-readable explanation of the status code.

	@see https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
**/
enum abstract StatusMessage(String) from String to String {
	// --- 1xx: Information ---

	/**
	 * This interim response indicates that everything so far is OK and that the
	 * client should continue the request, or ignore the response if the request
	 * is already finished.
	 */
	var CONTINUE = "Continue";

	/**
	 * This code is sent in response to an `Upgrade` request header from the client,
	 * and indicates the protocol the server is switching to.
	 */
	var SWITCHING_PROTOCOL = "Switching Protocols";

	/**
	 * This code indicates that the server has received and is processing the request,
	 * but no response is available yet.
	 */
	var PROCESSING = "Processing (WebDAV)";

	/**
	 * This status code is primarily intended to be used with the `Link` header,
	 * letting the user agent start preloading resources while the server prepares a response.
	 */
	var EARLY_HINTS = "Early Hints";

	// --- 2xx: Successful ---

	/**
	 * The request has succeeded.
	 */
	var OK = "OK";

	/**
	 * The request has succeeded and a new resource has been created as a result.
	 */
	var CREATED = "Created";

	/**
	 * The request has been received but not yet acted upon.
	 */
	var ACCEPTED = "Accepted";

	/**
	 * The returned meta-information is not exactly the same as is available from the origin server,
	 * but is collected from a local or a third-party copy.
	 */
	var NON_AUTORITATIVE_INFORMATION = "Non-Authoritative Information";

	/**
	 * There is no content to send for this request, but the headers may be useful.
	 */
	var NO_CONTENT = "No Content";

	/**
	 * Tells the user-agent to reset the document which sent this request.
	 */
	var RESET_CONTENT = "Reset Content";

	/**
	 * This response code is used when the `Range` header is sent from the client
	 * to request only part of a resource.
	 */
	var PARTIAL_CONTENT = "Partial Content";

	// --- 3xx: Redirection ---

	/**
	 * The request has more than one possible response.
	 */
	var MULTIPLE_CHOICE = "Multiple Choices";

	/**
	 * The URL of the requested resource has been changed permanently.
	 */
	var MOVED_PERMANENTLY = "Moved Permanently";

	/**
	 * This response code means that the URI of the requested resource has been changed temporarily.
	 */
	var FOUND = "Found";

	/**
	 * The server sent this response to direct the client to get the requested resource
	 * at another URI with a GET request.
	 */
	var SEE_OTHER = "See Other";

	/**
	 * This is used for caching purposes. It tells the client that the response has not been modified,
	 * so the client can continue to use the same cached version of the response.
	 */
	var NOT_MODIFIED = "Not Modified";

	/**
	 * Was defined in a previous version of the HTTP specification to indicate that a requested response
	 * must be accessed by a proxy. It has been deprecated due to security concerns regarding in-band configuration of a proxy.
	 */
	var USE_PROXY = "Use Proxy";

	/**
	 * This response code is no longer used.
	 */
	var SWITCH_PROXY = "Switch Proxy";

	/**
	 * The server sends this response to direct the client to get the requested resource
	 * at another URI with same method that was used in the prior request.
	 */
	var TEMPORARY_REDIRECT = "Temporary Redirect";

	/**
	 * This means that the resource is now permanently located at another URI,
	 * specified by the `Location:` HTTP Response header.
	 */
	var PERMANENT_REDIRECT = "Permanent Redirect";

	// --- 4xx: Client Error ---

	/**
	 * The client does not have access rights to the content.
	 */
	var FORBIDDEN = "Forbidden";

	/**
	 * The server can not find the requested resource.
	 */
	var NOT_FOUND = "Not Found";

	/**
	 * The request method is known by the server but has been disabled and cannot be used.
	 */
	var METHOD_NOT_ALLOWED = "Method Not Allowed";

	/**
	 * This response is sent when the web server, after performing server-driven content negotiation,
	 * doesn't find any content that conforms to the criteria given by the user agent.
	 */
	var NOT_ACCEPTABLE = "Not Acceptable";

	/**
	 * This is similar to 401 but authentication is needed to be done by a proxy.
	 */
	var PROXY_AUTHENTICATION_REQUIRED = "Proxy Authentication Required";

	/**
	 * This response is sent on an idle connection by some servers,
	 * even without any previous request by the client.
	 */
	var REQUEST_TIMEOUT = "Request Timeout";

	/**
	 * This response is sent when a request conflicts with the current state of the server.
	 */
	var CONFLICT = "Conflict";

	/**
	 * This response is sent when the requested content has been permanently deleted from server,
	 * with no forwarding address.
	 */
	var GONE = "Gone";

	/**
	 * Server rejected the request because the `Content-Length` header field is not defined and the server requires it.
	 */
	var LENGTH_REQUIRED = "Length Required";

	/**
	 * The client has indicated preconditions in its headers which the server does not meet.
	 */
	var PRECONDITION_FAILED = "Precondition Failed";

	/**
	 * Request entity is larger than limits defined by server.
	 */
	var REQUEST_ENTITY_TOO_LARGE = "Request Entity Too Large";

	/**
	 * The URI requested by the client is longer than the server is willing to interpret.
	 */
	var REQUEST_URI_TOO_LARGE = "Request-URI Too Long";

	/**
	 * The media format of the requested data is not supported by the server,
	 * so the server is rejecting the request.
	 */
	var UNSUPPORTED_MEDIA_TYPE = "Unsupported Media Type";

	/**
	 * The range specified by the `Range` header field in the request can't be fulfilled.
	 */
	var REQUEST_RANGE_NOT_SATISFIABLE = "Requested Range Not Satisfiable";

	/**
	 * This response code means the expectation indicated by the `Expect` request header field
	 * could not be met by the server.
	 */
	var EXPECTATION_FAILED = "Expectation Failed";

	// --- 5xx: Server Error ---

	/**
	 * The server has encountered a situation it doesn't know how to handle.
	 */
	var INTERNAL_SERVER_ERROR = "Internal Server Error";

	/**
	 * The request method is not supported by the server and cannot be handled.
	 */
	var NOT_IMPLEMENTED = "Not Implemented";

	/**
	 * This error response means that the server, while working as a gateway to get a response needed to handle the request,
	 * got an invalid response.
	 */
	var BAD_GATEWAY = "Bad Gateway";

	/**
	 * The server is not ready to handle the request.
	 */
	var SERVICE_UNAVAILABLE = "Service Unavailable";

	/**
	 * This error response is given when the server is acting as a gateway and cannot get a response in time.
	 */
	var GATEWAY_TIMEOUT = "Gateway Timeout";

	/**
	 * The HTTP version used in the request is not supported by the server.
	 */
	var HTTP_VERSION_NOT_SUPPORTED = "HTTP Version Not Supported";

	/**
	 * The client needs to authenticate to gain network access.
	 */
	var NETWORK_AUTHENTICATION_REQUIRED = "Network Authentication Required";

	@:to public inline function toBytes():Bytes
		return Bytes.ofString(this);

	/**
	 * Returns the `StatusMessage` corresponding to the given `StatusCode`.
	 * @param code The `StatusCode` to convert.
	 * @return The corresponding `StatusMessage`, or `null` if no match is found.
	 */
	@:from public static function fromStatusCode(code:StatusCode):StatusMessage {
		return switch code {
			case StatusCode.CONTINUE: StatusMessage.CONTINUE;
			case StatusCode.SWITCHING_PROTOCOL: StatusMessage.SWITCHING_PROTOCOL;
			case StatusCode.PROCESSING: StatusMessage.PROCESSING;
			case StatusCode.EARLY_HINTS: StatusMessage.EARLY_HINTS;

			case StatusCode.MULTIPLE_CHOICE: StatusMessage.MULTIPLE_CHOICE;
			case StatusCode.MOVED_PERMANENTLY: StatusMessage.MOVED_PERMANENTLY;
			case StatusCode.FOUND: StatusMessage.FOUND;
			case StatusCode.SEE_OTHER: StatusMessage.SEE_OTHER;
			case StatusCode.NOT_MODIFIED: StatusMessage.NOT_MODIFIED;
			case StatusCode.USE_PROXY: StatusMessage.USE_PROXY;
			case StatusCode.SWITCH_PROXY: StatusMessage.SWITCH_PROXY;
			case StatusCode.TEMPORARY_REDIRECT: StatusMessage.TEMPORARY_REDIRECT;
			case StatusCode.PERMANENT_REDIRECT: StatusMessage.PERMANENT_REDIRECT;

			case StatusCode.OK: StatusMessage.OK;
			case StatusCode.CREATED: StatusMessage.CREATED;
			case StatusCode.ACCEPTED: StatusMessage.ACCEPTED;
			case StatusCode.NON_AUTORITATIVE_INFORMATION: StatusMessage.NON_AUTORITATIVE_INFORMATION;
			case StatusCode.NO_CONTENT: StatusMessage.NO_CONTENT;
			case StatusCode.RESET_CONTENT: StatusMessage.RESET_CONTENT;
			case StatusCode.PARTIAL_CONTENT: StatusMessage.PARTIAL_CONTENT;

			case StatusCode.FORBIDDEN: StatusMessage.FORBIDDEN;
			case StatusCode.NOT_FOUND: StatusMessage.NOT_FOUND;
			case StatusCode.METHOD_NOT_ALLOWED: StatusMessage.METHOD_NOT_ALLOWED;
			case StatusCode.NOT_ACCEPTABLE: StatusMessage.NOT_ACCEPTABLE;
			case StatusCode.PROXY_AUTHENTICATION_REQUIRED: StatusMessage.PROXY_AUTHENTICATION_REQUIRED;
			case StatusCode.REQUEST_TIMEOUT: StatusMessage.REQUEST_TIMEOUT;
			case StatusCode.CONFLICT: StatusMessage.CONFLICT;
			case StatusCode.GONE: StatusMessage.GONE;
			case StatusCode.LENGTH_REQUIRED: StatusMessage.LENGTH_REQUIRED;
			case StatusCode.PRECONDITION_FAILED: StatusMessage.PRECONDITION_FAILED;
			case StatusCode.REQUEST_ENTITY_TOO_LARGE: StatusMessage.REQUEST_ENTITY_TOO_LARGE;
			case StatusCode.REQUEST_URI_TOO_LARGE: StatusMessage.REQUEST_URI_TOO_LARGE;
			case StatusCode.UNSUPPORTED_MEDIA_TYPE: StatusMessage.UNSUPPORTED_MEDIA_TYPE;
			case StatusCode.REQUEST_RANGE_NOT_SATISFIABLE: StatusMessage.REQUEST_RANGE_NOT_SATISFIABLE;
			case StatusCode.EXPECTATION_FAILED: StatusMessage.EXPECTATION_FAILED;

			case StatusCode.INTERNAL_SERVER_ERROR: StatusMessage.INTERNAL_SERVER_ERROR;
			case StatusCode.NOT_IMPLEMENTED: StatusMessage.NOT_IMPLEMENTED;
			case StatusCode.BAD_GATEWAY: StatusMessage.BAD_GATEWAY;
			case StatusCode.SERVICE_UNAVAILABLE: StatusMessage.SERVICE_UNAVAILABLE;
			case StatusCode.GATEWAY_TIMEOUT: StatusMessage.GATEWAY_TIMEOUT;
			case StatusCode.HTTP_VERSION_NOT_SUPPORTED: StatusMessage.HTTP_VERSION_NOT_SUPPORTED;
			case StatusCode.NETWORK_AUTHENTICATION_REQUIRED: StatusMessage.NETWORK_AUTHENTICATION_REQUIRED;

			case _: null;
		}
	}
}
