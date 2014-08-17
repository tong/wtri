package haxe.net;

class HTTPError {

	public var code : Int;

	public function new( code : Int ) {
		this.code = code;
	}

	public function toString() : String {
		return 'HTTPError $code';
	}

}
