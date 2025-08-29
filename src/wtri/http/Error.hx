package wtri.http;

class Error {
	public final code:StatusCode;
	public final message:StatusMessage;

	public inline function new(code:StatusCode, ?message:StatusMessage) {
		this.code = code;
		this.message = message ?? StatusMessage.fromStatusCode(code);
	}
}
