package wtri.http;

enum abstract StatusCode(Int) from Int to Int {

	// --- 1xx Informational - Request received, continuing process

	/**
		The server has received the request headers and the client should proceed to send the request body
	*/
	var CONTINUE = 100;

	/**
		The requester has asked the server to switch protocols and the server has agreed to do so
	*/
	var SWITCHING_PROTOCOL = 101;
	var PROCESSING = 102;
	var EARLY_HINTS = 103;

	// --- 2xx Success - The action was successfully received, understood, and accepted

	var OK = 200;
	var CREATED = 201;
	var ACCEPTED = 202;
	var NON_AUTORITATIVE_INFORMATION = 203;
	var NO_CONTENT = 204;
	var RESET_CONTENT = 205;
	var PARTIAL_CONTENT = 206;
	var MULTI_STATUS = 207;
	var ALREADY_REPORTED = 208;

	var IM_USED = 226;

	var LOW_ON_STORAGE_SPACE = 250;

	// --- 3xx Redirection - Further action must be taken in order to complete the request

	var MULTIPLE_CHOICE = 300;
	var MOVED_PERMANENTLY = 301;
	var FOUND = 302;
	var SEE_OTHER = 303;
	var NOT_MODIFIED = 304;
	var USE_PROXY = 305;
	var SWITCH_PROXY = 306;
	var TEMPORARY_REDIRECT = 307;
	var PERMANENT_REDIRECT = 308;

	// --- 4xx Client Error - The request contains bad syntax or cannot be fulfilled

	var BAD_REQUEST = 400;
	var UNAUTHORIZED = 401;
	var PAYMENT_REQUIRED = 402;
	var FORBIDDEN = 403;

	/**
		The requested resource could not be found but may be available in the future.
		Subsequent requests by the client are permissible.
	*/
	var NOT_FOUND = 404;
	var METHOD_NOT_ALLOWED = 405;
	var NOT_ACCEPTABLE = 406;
	var PROXY_AUTHENTICATION_REQUIRED = 407;
	var REQUEST_TIMEOUT = 408;
	var CONFLICT = 409;
	var GONE = 410;
	var LENGTH_REQUIRED = 411;
	var PRECONDITION_FAILED = 412;

	var REQUEST_ENTITY_TOO_LARGE = 413;
	var REQUEST_URI_TOO_LARGE = 414;
	var UNSUPPORTED_MEDIA_TYPE = 415;
	var REQUEST_RANGE_NOT_SATISFIABLE = 416;
	var EXPECTATION_FAILED = 417;
	var I_AM_A_TEAPOT = 418;
	var AUTHENTICATION_TIMEOUT = 419;
	var METHOD_FAILURE = 420;
	var ENHANCE_YOUR_CALM = 420;
	var UNPROCESSABLE_ENTITY = 422;
	var LOCKED = 423;
	var FAILED_DEPENDENCY = 424;
	//var METHOD_FAILURE = 424;
	var UNORDERED_COLLECTION = 425;
	var UPGRADE_REQUIRED = 426;
	var PRECONDITION_REQUIRED = 428;
	var TOO_MANY_REQUESTS = 429;
	var REQUEST_HEADER_FIELDS_TOO_LARGE = 431;
	var NO_RESPONSE = 444;
	var RETRY_WITH = 449;
	var BLOCKED_BY_WINDOWS_PARENTAL_CONTROLS = 450;
	var UNAVAILABLE_FOR_LEGAL_REASONS = 451;
	var REDIRECT = 451;
	var REQUEST_HEADER_TOO_LARGE = 494;
	var CERT_ERROR = 495;
	var NO_CERT = 496;
	var HTTP_TO_HTTPS = 497;
	var CLIENT_CLOSED_REQUEST = 499;

	// --- 5xx Server Error - The server failed to fulfill an apparently valid request

	/**
		The server either does not recognize the request method, or it lacks the ability to fulfil the request
	*/
	var INTERNAL_SERVER_ERROR = 500;
	var NOT_IMPLEMENTED = 501;
	var BAD_GATEWAY = 502;
	var SERVICE_UNAVAILABLE = 503;
	var GATEWAY_TIMEOUT = 504;
	var HTTP_VERSION_NOT_SUPPORTED = 505;
	var VARIANT_ALSO_NEGOTIATES = 506;
	var INSUFFICIENTS_STORAGE = 507;
	var LOOP_DETECTED = 508;
	var BANDWITH_LIMIT_EXCEEDED = 509;
	var NOT_EXTENDED = 510;
	var NETWORK_AUTHENTICATION_REQUIRED = 511;
	var NETWORK_READ_TIMEOUT_ERROR = 598;
	var NETWORK_CONNECT_TIMEOUT_ERROR = 599;
}
