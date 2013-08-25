package haxe.net;

class HTTPError {

	public var statusCode : Int;

	public function new( statusCode : Int ) {
		this.statusCode = statusCode;
	}

	public function toString() : String {
		return 'HTTPError $statusCode';
	}

}
