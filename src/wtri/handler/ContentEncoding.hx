package wtri.handler;

typedef Encoder = Bytes->Bytes;

class ContentEncoding implements wtri.Handler {
	public var encoders:Map<String, Encoder>;

	public function new(encoders:Map<String, Encoder>) {
		this.encoders = encoders;
	}

	public function handle(req:Request, res:Response):Bool {
		if (res.finished || res.body == null)
			return false;
		var enc = req.getEncoding();
		for (k in encoders.keys()) {
			if (enc.indexOf(k) != -1) {
				// Read the original body into memory for compression
				final uncompressedBytes = res.body.readAll();
				res.body.close();

				// Apply the compression (Bytes -> Bytes)
				final compressedBytes = encoders.get(k)(uncompressedBytes);

				trace("content encoding", uncompressedBytes.length, compressedBytes.length);
				// Set the new body to a stream of the compressed bytes
				res.body = new haxe.io.BytesInput(compressedBytes);

				// Update headers to reflect compression
				res.headers.set(Content_Encoding, k);
				res.headers.set(Content_Length, Std.string(compressedBytes.length));
				return true;
			}
		}
		return false;
	}
}
