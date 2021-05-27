package wtri.http;

enum abstract HeaderName(String) from String to String {
	// --- Authentication
	var WWW_Authenticate = "WWW-Authenticate";
	var Authorization = "Authorization";
	var Proxy_Authenticate = "Proxy-Authenticate";
	var Proxy_Authorization = "Proxy-Authorization";
	// --- Caching
	var Age = "Age";
	var Cache_Control = "Cache-Control";
	var Clear_Site_Data = "Clear-Site-Data";
	var Expires = "Expires";
	var Warning = "Warning";
	// --- Conditionals
	var Last_Modified = "Last-Modified";
	var ETag = "ETag";
	var If_Match = "If-Match";
	var If_None_Match = "If-None-Match";
	var If_Modified_Since = "If-Modified-Since";
	var If_Unmodified_Since = "If-Unmodified-Since";
	var Vary = "Vary";
	// --- Connection management
	var Connection = "Connection";
	var Keep_Alive = "Keep-Alive";
	// --- Content negotiation
	var Accept = "Accept";
	var Accept_Encoding = "Accept-Encoding";
	var Accept_Language = "Accept-Language";
	// --- Controls
	var Cookie = "Cookie";
	var Set_Cookie = "Set-Cookie";
	// --- CORS
	var Access_Control_Allow_Origin = "Access-Control-Allow-Origin";
	var Access_Control_Allow_Credentials = "Access-Control-Allow-Credentials";
	var Access_Control_Allow_Headers = "Access-Control-Allow-Headers";
	var Access_Control_Allow_Methods = "Access-Control-Allow-Methods";
	var Access_Control_Expose_Headers = "Access-Control-Expose-Headers";
	var Access_Control_Max_Age = "Access-Control-Max-Age";
	var Access_Control_Request_Headers = "Access-Control-Request-Headers";
	var Access_Control_Request_Method = "Access-Control-Request-Method";
	var Origin = "Origin";
	var Timing_Allow_Origin = "Timing-Allow-Origin";
	// --- Downloads
	var Content_Disposition = "Content-Disposition";
	// --- Message body information
	var Content_Length = "Content-Length";
	var Content_Type = "Content-Type";
	var Content_Encoding = "Content-Encoding";
	var Content_Language = "Content-Language";
	var Content_Location = "Content-Location";
	// --- Proxies
	var Forwarded = "Forwarded";
	var Via = "Via";
	// --- Redirects
	var Location = "Location";
	// --- Redirects
	var From = "From";
	var Host = "Host";
	var Referer = "Referer";
	var Referrer_Policy = "Referrer-Policy";
	var User_Agent = "User-Agent";
	// --- Response context
	var Allow = "Allow";
	var Server = "Server";
	// --- Range requests
	var Accept_Ranges = "Accept-Ranges";
	var Range = "Range";
	var If_Range = "If-Range";
	var Content_Range = "Content-Range";
	// --- Security
	var Content_Security_Policy = "Content-Security-Policy";
	var Content_Security_Policy_Report_Only = "Content-Security-Policy-Report-Only";
	var Expect_CT = "Expect-CT";
	var Feature_Policy = "Feature-Policy";
	var Strict_Transport_Security = "Strict-Transport-Security";
	var Upgrade_Insecure_Requests = "Upgrade-Insecure-Requests";
	var X_Content_Type_Options = "X-Content-Type-Options";
	var X_Download_Options = "X-Download-Options";
	var X_Frame_Options = "X-Frame-Options";
	var X_Permitted_Cross_Domain_Policies = "X-Permitted-Cross-Domain-Policies";
	var X_Powered_By = "X-Powered-By";
	var X_XSS_Protection = "X-XSS-Protection";
	// --- Server-sent events
	var Last_Event_ID = "Last-Event-ID";
	var NEL = "NEL";
	var Ping_From = "Ping-From";
	var Ping_To = "Ping-To";
	var Report_To = "Report-To";
	// --- Transfer coding
	var Transfer_Encoding = "Transfer-Encoding";
	var TE = "TE";
	var Trailer = "Trailer";
	// --- WebSockets
	var Sec_WebSocket_Key = "Sec-WebSocket-Key";
	var Sec_WebSocket_Extensions = "Sec-WebSocket-Extensions";
	var Sec_WebSocket_Accept = "Sec-WebSocket-Accept";
	var Sec_WebSocket_Protocol = "Sec-WebSocket-Protocol";
	var Sec_WebSocket_Version = "Sec-WebSocket-Version";
	// --- Other
	var Accept_Push_Policy = "Accept-Push-Policy";
	var Accept_Signature = "Accept-Signature";
	var Alt_Svc = "Alt-Svc";
	var Date = "Date";
	var Large_Allocation = "Large-Allocation";
	var Link = "Link";
	var Push_Policy = "Push-Policy";
	var Retry_After = "Retry-After";
	var Signature = "Signature";
	var Signed_Headers = "Signed-Headers";
	var Server_Timing = "Server-Timing";
	var Service_Worker_Allowed = "Service-Worker-Allowed";
	var SourceMap = "SourceMap";
	var Upgrade = "Upgrade";
	var X_DNS_Prefetch_Control = "X-DNS-Prefetch-Control";
	var X_Requested_With = "X-Requested-With";
	var X_Robots_Tag = "X-Robots-Tag";
}
