package wtri.http;

/**
	Represents an HTTP header name.

	@see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers
**/
enum abstract HeaderName(String) from String to String {
	// --- Authentication ---

	/**
	 * Defines the authentication method that should be used to access a resource.
	 */
	var WWW_Authenticate = "WWW-Authenticate";

	/**
	 * Contains the credentials to authenticate a user agent with a server.
	 */
	var Authorization = "Authorization";

	/**
	 * Defines the authentication method that should be used to access a resource behind a proxy server.
	 */
	var Proxy_Authenticate = "Proxy-Authenticate";

	/**
	 * Contains the credentials to authenticate a user agent with a proxy server.
	 */
	var Proxy_Authorization = "Proxy-Authorization";

	// --- Caching ---

	/**
	 * The time, in seconds, that the object has been in a proxy cache.
	 */
	var Age = "Age";

	/**
	 * Directives for caching mechanisms in both requests and responses.
	 */
	var Cache_Control = "Cache-Control";

	/**
	 * Clears browsing data (e.g. cookies, storage, cache) associated with the requesting website.
	 */
	var Clear_Site_Data = "Clear-Site-Data";

	/**
	 * The date/time after which the response is considered stale.
	 */
	var Expires = "Expires";

	/**
	 * A general warning about possible problems with the status of the message.
	 */
	var Warning = "Warning";

	// --- Conditionals ---

	/**
	 * The last modification date of the resource, used to compare several versions of the same resource.
	 */
	var Last_Modified = "Last-Modified";

	/**
	 * A unique string identifying the version of the resource.
	 */
	var ETag = "ETag";

	/**
	 * Makes the request conditional, and applies the method only if the stored resource matches one of the given ETags.
	 */
	var If_Match = "If-Match";

	/**
	 * Makes the request conditional, and applies the method only if the stored resource does not match any of the given ETags.
	 */
	var If_None_Match = "If-None-Match";

	/**
	 * Makes the request conditional, and expects the entity to be transmitted only if it has been modified after the given date.
	 */
	var If_Modified_Since = "If-Modified-Since";

	/**
	 * Makes the request conditional, and expects the entity to be transmitted only if it has not been modified after the given date.
	 */
	var If_Unmodified_Since = "If-Unmodified-Since";

	/**
	 * Determines how to match future request headers to decide whether a cached response can be used rather than requesting a fresh one from the origin server.
	 */
	var Vary = "Vary";

	// --- Connection management ---

	/**
	 * Controls whether the network connection stays open after the current transaction finishes.
	 */
	var Connection = "Connection";

	/**
	 * Controls how long a persistent connection should stay open.
	 */
	var Keep_Alive = "Keep-Alive";

	// --- Content negotiation ---

	/**
	 * Informs the server about the types of data that can be sent back.
	 */
	var Accept = "Accept";

	/**
	 * The encoding algorithm, usually a compression algorithm, that can be used on the resource sent back.
	 */
	var Accept_Encoding = "Accept-Encoding";

	/**
	 * Informs the server about the human language the server is expected to send back.
	 */
	var Accept_Language = "Accept-Language";

	// --- Cookies ---

	/**
	 * Contains stored HTTP cookies previously sent by the server with the `Set-Cookie` header.
	 */
	var Cookie = "Cookie";

	/**
	 * Send cookies from the server to the user-agent.
	 */
	var Set_Cookie = "Set-Cookie";

	// --- CORS ---

	/**
	 * Indicates whether the response can be shared with requesting code from the given origin.
	 */
	var Access_Control_Allow_Origin = "Access-Control-Allow-Origin";

	/**
	 * Indicates whether the response to the request can be exposed when the credentials flag is true.
	 */
	var Access_Control_Allow_Credentials = "Access-Control-Allow-Credentials";

	/**
	 * Used in response to a preflight request to indicate which HTTP headers can be used during the actual request.
	 */
	var Access_Control_Allow_Headers = "Access-Control-Allow-Headers";

	/**
	 * Specifies the methods allowed when accessing the resource in response to a preflight request.
	 */
	var Access_Control_Allow_Methods = "Access-Control-Allow-Methods";

	/**
	 * Indicates which headers can be exposed as part of the response by listing their names.
	 */
	var Access_Control_Expose_Headers = "Access-Control-Expose-Headers";

	/**
	 * Indicates how long the results of a preflight request can be cached.
	 */
	var Access_Control_Max_Age = "Access-Control-Max-Age";

	/**
	 * Used when issuing a preflight request to let the server know which HTTP headers will be used when the actual request is made.
	 */
	var Access_Control_Request_Headers = "Access-Control-Request-Headers";

	/**
	 * Used when issuing a preflight request to let the server know which HTTP method will be used when the actual request is made.
	 */
	var Access_Control_Request_Method = "Access-Control-Request-Method";

	/**
	 * Indicates where a fetch originates from.
	 */
	var Origin = "Origin";

	/**
	 * Specifies origins that are allowed to see values of attributes retrieved via features of the Resource Timing API, which would otherwise be reported as zero due to cross-origin restrictions.
	 */
	var Timing_Allow_Origin = "Timing-Allow-Origin";

	// --- Downloads ---

	/**
	 * Indicates if the resource transmitted should be displayed inline (default behavior without the header), or if it should be handled like a download and the browser should present a "Save As" dialog.
	 */
	var Content_Disposition = "Content-Disposition";

	// --- Message body information ---

	/**
	 * The size of the resource, in decimal number of bytes.
	 */
	var Content_Length = "Content-Length";

	/**
	 * Indicates the media type of the resource.
	 */
	var Content_Type = "Content-Type";

	/**
	 * Used to specify the compression algorithm.
	 */
	var Content_Encoding = "Content-Encoding";

	/**
	 * Describes the human language(s) intended for the audience.
	 */
	var Content_Language = "Content-Language";

	/**
	 * Indicates an alternate location for the returned data.
	 */
	var Content_Location = "Content-Location";

	// --- Proxies ---

	/**
	 * Contains information from the client-facing side of proxy servers that is altered or lost when a proxy is involved in the path of the request.
	 */
	var Forwarded = "Forwarded";

	/**
	 * Added by proxies, both forward and reverse proxies, and can appear in the request headers and the response headers.
	 */
	var Via = "Via";

	// --- Redirects ---

	/**
	 * Indicates the URL to redirect a page to.
	 */
	var Location = "Location";

	// --- Request context ---

	/**
	 * Contains an Internet email address for a human user who controls the requesting user agent.
	 */
	var From = "From";

	/**
	 * Specifies the domain name of the server (for virtual hosting), and (optionally) the TCP port number on which the server is listening.
	 */
	var Host = "Host";

	/**
	 * The address of the previous web page from which a link to the currently requested page was followed.
	 */
	var Referer = "Referer";

	/**
	 * Governs which referrer information, sent in the `Referer` header, should be included with requests made.
	 */
	var Referrer_Policy = "Referrer-Policy";

	/**
	 * A characteristic string that lets the network protocol peers identify the application type, operating system, software vendor or software version of the requesting software user agent.
	 */
	var User_Agent = "User-Agent";

	// --- Response context ---

	/**
	 * Lists the set of methods supported by a resource.
	 */
	var Allow = "Allow";

	/**
	 * Contains information about the software used by the origin server to handle the request.
	 */
	var Server = "Server";

	// --- Range requests ---

	/**
	 * Indicates if the server supports range requests, and if so, in which unit the range can be expressed.
	 */
	var Accept_Ranges = "Accept-Ranges";

	/**
	 * Indicates the part of a document that the server should return.
	 */
	var Range = "Range";

	/**
	 * Creates a conditional range request that is only fulfilled if the given etag or date matches the remote resource.
	 */
	var If_Range = "If-Range";

	/**
	 * Indicates where in a full body message a partial message belongs.
	 */
	var Content_Range = "Content-Range";

	// --- Security ---

	/**
	 * Allows web site administrators to control resources the user agent is allowed to load for a given page.
	 */
	var Content_Security_Policy = "Content-Security-Policy";

	/**
	 * Allows web developers to experiment with policies by monitoring, but not enforcing, their effects.
	 */
	var Content_Security_Policy_Report_Only = "Content-Security-Policy-Report-Only";

	/**
	 * Allows sites to opt in to reporting and/or enforcement of Certificate Transparency requirements.
	 */
	var Expect_CT = "Expect-CT";

	/**
	 * Provides a mechanism to allow and deny the use of browser features in its own frame, and in content within any `<iframe>` elements in the document.
	 */
	var Feature_Policy = "Feature-Policy";

	/**
	 * Sends a signal to the server expressing the client's preference for an encrypted and authenticated response, and that it can successfully handle the `upgrade-insecure-requests` CSP directive.
	 */
	var Strict_Transport_Security = "Strict-Transport-Security";

	/**
	 * A security header that prevents browsers from MIME-sniffing a response away from the declared `Content-Type`.
	 */
	var Upgrade_Insecure_Requests = "Upgrade-Insecure-Requests";

	/**
	 * A security header that prevents browsers from MIME-sniffing a response away from the declared `Content-Type`.
	 */
	var X_Content_Type_Options = "X-Content-Type-Options";

	/**
	 * A security header that indicates that the browser should not display the option to "Open" a file, but only to "Save" it.
	 */
	var X_Download_Options = "X-Download-Options";

	/**
	 * A security header that indicates whether or not a browser should be allowed to render a page in a `<frame>`, `<iframe>`, `<embed>` or `<object>`.
	 */
	var X_Frame_Options = "X-Frame-Options";

	/**
	 * A security header that specifies a policy for handling of content in a cross-domain context.
	 */
	var X_Permitted_Cross_Domain_Policies = "X-Permitted-Cross-Domain-Policies";

	/**
	 * A de-facto standard for identifying the technology supporting a web application.
	 */
	var X_Powered_By = "X-Powered-By";

	/**
	 * A security header that enables cross-site scripting filtering.
	 */
	var X_XSS_Protection = "X-XSS-Protection";

	// --- Server-sent events ---

	/**
	 * The last event ID of the event source.
	 */
	var Last_Event_ID = "Last-Event-ID";

	/**
	 * A header that defines a network error logging policy.
	 */
	var NEL = "NEL";

	/**
	 * A header that is used to check the availability of the server.
	 */
	var Ping_From = "Ping-From";

	/**
	 * A header that is used to check the availability of the server.
	 */
	var Ping_To = "Ping-To";

	/**
	 * A header that specifies a URL to which a browser should send reports about policy violations.
	 */
	var Report_To = "Report-To";

	// --- Transfer coding ---

	/**
	 * Specifies the form of encoding used to safely transfer the entity to the user.
	 */
	var Transfer_Encoding = "Transfer-Encoding";

	/**
	 * The transfer encodings the user agent is willing to accept.
	 */
	var TE = "TE";

	/**
	 * The trailer fields that are present in the trailer part of a message encoded with chunked transfer coding.
	 */
	var Trailer = "Trailer";

	// --- WebSockets ---

	/**
	 * A key that is used in the WebSocket handshake.
	 */
	var Sec_WebSocket_Key = "Sec-WebSocket-Key";

	/**
	 * A header that is used to select a subprotocol.
	 */
	var Sec_WebSocket_Extensions = "Sec-WebSocket-Extensions";

	/**
	 * A header that is used in the WebSocket handshake.
	 */
	var Sec_WebSocket_Accept = "Sec-WebSocket-Accept";

	/**
	 * A header that is used to select a subprotocol.
	 */
	var Sec_WebSocket_Protocol = "Sec-WebSocket-Protocol";

	/**
	 * A header that is used to select a subprotocol.
	 */
	var Sec_WebSocket_Version = "Sec-WebSocket-Version";

	// --- Other ---

	/**
	 * A header that is used to accept a push policy.
	 */
	var Accept_Push_Policy = "Accept-Push-Policy";

	/**
	 * A header that is used to accept a signature.
	 */
	var Accept_Signature = "Accept-Signature";

	/**
	 * A header that is used to advertise alternative services.
	 */
	var Alt_Svc = "Alt-Svc";

	/**
	 * The date and time at which the message was originated.
	 */
	var Date = "Date";

	/**
	 * A header that is used to request a large allocation.
	 */
	var Large_Allocation = "Large-Allocation";

	/**
	 * A header that is used to express a relationship between two resources.
	 */
	var Link = "Link";

	/**
	 * A header that is used to define a push policy.
	 */
	var Push_Policy = "Push-Policy";

	/**
	 * Indicates how long the user agent should wait before making a follow-up request.
	 */
	var Retry_After = "Retry-After";

	/**
	 * A header that is used to carry a signature for a message.
	 */
	var Signature = "Signature";

	/**
	 * A header that is used to list the headers of a message that are included in the signature.
	 */
	var Signed_Headers = "Signed-Headers";

	/**
	 * A header that is used to communicate one or more metrics and descriptions for the given request-response cycle.
	 */
	var Server_Timing = "Server-Timing";

	/**
	 * A header that is used to define a scope for a service worker.
	 */
	var Service_Worker_Allowed = "Service-Worker-Allowed";

	/**
	 * A header that is used to link to a source map for a resource.
	 */
	var SourceMap = "SourceMap";

	/**
	 * A header that is used to upgrade a connection to a different protocol.
	 */
	var Upgrade = "Upgrade";

	/**
	 * A header that is used to control DNS prefetching.
	 */
	var X_DNS_Prefetch_Control = "X-DNS-Prefetch-Control";

	/**
	 * A header that is used to identify Ajax requests.
	 */
	var X_Requested_With = "X-Requested-With";

	/**
	 * A header that is used to control the behavior of search engine robots.
	 */
	var X_Robots_Tag = "X-Robots-Tag";
}
