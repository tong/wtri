package wtri.http;

/**
	@see https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
*/
enum abstract Method(String) from String to String {

	/**
		The GET method means retrieve whatever information (in the form of an entity) is identified by the Request-URI. If the Request-URI refers to a data-producing process, it is the produced data which shall be returned as the entity in the response and not the source text of the process, unless that text happens to be the output of the process.
	*/
	var GET;

	/**
		The HEAD method is identical to GET except that the server MUST NOT return a message-body in the response.
		The metainformation contained in the HTTP headers in response to a HEAD request SHOULD be identical to the information sent in response to a GET request.
		This method can be used for obtaining metainformation about the entity implied by the request without transferring the entity-body itself.
		This method is often used for testing hypertext links for validity, accessibility, and recent modification.
	*/
	var HEAD;

	/**
		The OPTIONS method represents a request for information about the communication options available on the request/response chain identified by the Request-URI.
		This method allows the client to determine the options and/or requirements associated with a resource, or the capabilities of a server, without implying a resource action or initiating a resource retrieval.
	*/
	var OPTIONS;

	/**
		The POST method is used to request that the origin server accept the entity enclosed in the request as a new subordinate of the resource identified by the Request-URI in the Request-Line.
	*/
	var POST;

	/**
		The PUT method requests that the enclosed entity be stored under the supplied Request-URI.
		If the Request-URI refers to an already existing resource, the enclosed entity SHOULD be considered as a modified version of the one residing on the origin server.
		If the Request-URI does not point to an existing resource, and that URI is capable of being defined as a new resource by the requesting user agent, the origin server can create the resource with that URI.
	*/
	var PUT;

	/**
		The PATCH method is used to apply partial modifications to a resource.
	*/
	var PATCH;

	/**
		The DELETE method requests that the origin server delete the resource identified by the Request-URI.
		This method MAY be overridden by human intervention (or other means) on the origin server.
		The client cannot be guaranteed that the operation has been carried out, even if the status code returned from the origin server indicates that the action has been completed successfully.
		However, the server SHOULD NOT indicate success unless, at the time the response is given, it intends to delete the resource or move it to an inaccessible location.
	*/
	var DELETE;

}
