package haxe.net;

class HTTPStatusCode {

	// 1xx Informational

	public static inline var CONTINUE = 100;
	public static inline var SWITCHING_PROTOCOLS = 101;
	public static inline var PROCESSING = 102;

	// --- 2xx Success

	public static inline var OK = 200;
	public static inline var CREATED = 201;
	public static inline var ACCEPTED = 202;
	public static inline var NON_AUTORITATIVE_INFORMATION = 203;
	public static inline var NO_CONTENT = 204;
	public static inline var RESET_CONTENT = 205;
	public static inline var PARTIAL_CONTENT = 206;
	public static inline var MULTI_STATUS = 207;
	public static inline var ALREADY_REPORTED = 208;
	public static inline var LOW_ON_STORAGE_SPACE = 250;
	public static inline var IM_USED = 226;
	
	// --- 3xx Redirection

	public static inline var MULTIPLE_CHOICE = 300;
	public static inline var MOVED_PERMANENTLY = 301;
	public static inline var FOUND = 302;
	public static inline var SEE_OTHER = 303;
	public static inline var NOT_MODIFIED = 304;
	public static inline var USE_PROXY = 305;
	public static inline var SWITCH_PROXY = 306;
	public static inline var TEMPORARY_REDIRECT = 307;
	public static inline var PERMANENT_REDIRECT = 308;

	// --- 4xx Client Error

	public static inline var BAD_REQUEST = 400;
	public static inline var UNAUTHORIZED = 401;
	public static inline var PAYMENT_REQUIRED = 402;
	public static inline var FORBIDDEN = 403;
	public static inline var NOT_FOUND = 404;
	public static inline var METHOD_NOT_ALLOWED = 405;
	public static inline var NOT_ACCEPTABLE = 406;
	public static inline var PROXY_AUTHENTICATION_REQUIRED = 407;
	public static inline var CONFLICT = 409;
	public static inline var GONE = 410;
	public static inline var LENGTH_REQUIRED = 411;
	public static inline var PRECONDITION_FAILED = 412;
	public static inline var REQUEST_ENTITY_TOO_LARGE = 413;
	public static inline var REQUEST_URI_TOO_LARGE = 414;
	public static inline var UNSUPPORTED_MEDIA_TYPE = 415;
	public static inline var REQUEST_RANGE_NOT_SATISFIABLE = 416;
	public static inline var EXPECTATION_FAILED = 417;
	public static inline var I_AM_A_TEAPOT = 418;
	public static inline var AUTHENTICATION_TIMEOUT = 419;
	public static inline var METHOD_FAILURE = 420;
	public static inline var ENHANCE_YOUR_CALM = 420;
	public static inline var UNPROCESSABLE_ENTITY = 422;
	public static inline var LOCKED = 423;
	public static inline var FAILED_DEPENDENCY = 424;
	//public static inline var METHOD_FAILURE = 424;
	public static inline var UNORDERED_COLLECTION = 425;
	public static inline var UPGRADE_REQUIRED = 426;
	public static inline var PRECONDITION_REQUIRED = 428;
	public static inline var TOO_MANY_REQUESTS = 429;
	public static inline var REQUEST_HEADER_FIELDS_TOO_LARGE = 431;
	public static inline var NO_RESPONSE = 444;
	public static inline var RETRY_WITH = 449;
	public static inline var BLOCKED_BY_WINDOWS_PARENTAL_CONTROLS = 450;
	public static inline var UNAVAILABLE_FOR_LEGAL_REASONS = 451;
	public static inline var REDIRECT = 451;
	public static inline var REQUEST_HEADER_TOO_LARGE = 494;
	public static inline var CERT_ERROR = 495;
	public static inline var NO_CERT = 496;
	public static inline var HTTP_TO_HTTPS = 497;
	public static inline var CLIENT_CLOSED_REQUEST = 499;

	// --- 5xx Server Error

	public static inline var INTERNAL_SERVER_ERROR = 500;
	public static inline var NOT_IMPLEMENTED = 501;
	public static inline var BAD_GATEWAY = 502;
	public static inline var SERVICE_UNAVAILABLE = 503;
	public static inline var GATEWAY_TIMEOUT = 504;
	public static inline var HTTP_VERSION_NOT_SUPPORTED = 505;
	public static inline var VARIANT_ALSO_NEGOTIATES = 506;
	public static inline var INSUFFICIENTS_STORAGE = 507;
	public static inline var LOOP_DETECTED = 508;
	public static inline var BANDWITH_LIMIT_EXCEEDED = 509;
	public static inline var NOT_EXTENDED = 510;
	public static inline var NETWORK_AUTHENTICATION_REQUIRED = 511;
	public static inline var NETWORK_READ_TIMEOUT_ERROR = 598;
	public static inline var NETWORK_CONNECT_TIMEOUT_ERROR = 599;

	/*
	public var code : String;
	public var text : String;

	public function new( code : String, ?text : String ) {
		this.code = code;
		this.text = text;
	}
	*/

}
