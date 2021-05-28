package wtri.http;

enum abstract StatusMessage(String) from String to String {

    // --- 1xx: Information
    
    var CONTINUE = "Continue";
    var SWITCHING_PROTOCOL = "Switching Protocols";
    var PROCESSING = "Processing (WebDAV)";
    var EARLY_HINTS = "Early Hints";
    
    // --- 2xx: Successful

    var OK = "OK";
    var CREATED = "Created";
    var ACCEPTED = "Accepted";
    var NON_AUTORITATIVE_INFORMATION = "Non-Authoritative Information";
    var NO_CONTENT = "No Content";
    var RESET_CONTENT = "Reset Content";
    var PARTIAL_CONTENT = "Partial Content";

    // --- 3xx: Redirection

    var MULTIPLE_CHOICE = "Multiple Choices";
    var MOVED_PERMANENTLY = "Moved Permanently";
    var FOUND = "Found";
    var SEE_OTHER = "See Other";
    var NOT_MODIFIED = "Not Modified";
    var USE_PROXY = "Use Proxy";
    var SWITCH_PROXY = "Switch Proxy";
    var TEMPORARY_REDIRECT = "Temporary Redirect";
    var PERMANENT_REDIRECT = "Resume Incomplete";

    // --- 4xx: Client Error

    var NOT_FOUND = "Not Found";
    var METHOD_NOT_ALLOWED = "Method Not Allowed";
	var NOT_ACCEPTABLE = "Not Acceptable";
	var PROXY_AUTHENTICATION_REQUIRED = "Proxy Authentication Required";
	var REQUEST_TIMEOUT = "Request Timeout";
	var CONFLICT = "Conflict";
	var GONE = "Gone";
	var LENGTH_REQUIRED = "Length Required";
	var PRECONDITION_FAILED = "Precondition Failed";
	var REQUEST_ENTITY_TOO_LARGE = "Request Entity Too Large";
	var REQUEST_URI_TOO_LARGE = "Request-URI Too Long";
	var UNSUPPORTED_MEDIA_TYPE = "Unsupported Media Type";
	var REQUEST_RANGE_NOT_SATISFIABLE = "Requested Range Not Satisfiable";
	var EXPECTATION_FAILED = "Expectation Failed";
    
    // --- 5xx: Server Error
    
	var INTERNAL_SERVER_ERROR = "Internal Server Error";
	var NOT_IMPLEMENTED = "Not Implemented";
	var BAD_GATEWAY = "Bad Gateway";
	var SERVICE_UNAVAILABLE = "Service Unavailable";
	var GATEWAY_TIMEOUT = "Gateway Timeout";
	var HTTP_VERSION_NOT_SUPPORTED = "HTTP Version Not Supported";
	var NETWORK_AUTHENTICATION_REQUIRED = "Network Authentication Required";

    public static function fromStatusCode( code : StatusCode ) : StatusMessage {

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
        case StatusCode.PERMANENT_REDIRECT: StatusMessage.TEMPORARY_REDIRECT;

        case StatusCode.OK: StatusMessage.OK;
        case StatusCode.CREATED: StatusMessage.CREATED;
        case StatusCode.ACCEPTED: StatusMessage.ACCEPTED;
        case StatusCode.NON_AUTORITATIVE_INFORMATION: StatusMessage.NON_AUTORITATIVE_INFORMATION;
        case StatusCode.NO_CONTENT: StatusMessage.NO_CONTENT;
        case StatusCode.RESET_CONTENT: StatusMessage.RESET_CONTENT;
        case StatusCode.PARTIAL_CONTENT: StatusMessage.PARTIAL_CONTENT;
       
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
