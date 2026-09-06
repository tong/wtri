package wtri.net;

interface Socket {
	function write(data:Bytes):Void;
	function writeInput(input:haxe.io.Input, len:Int):Void;
	function close():Void;
}

/**
	Chunk size used when streaming an `Input` to a socket, so large bodies
	(file downloads, ...) are sent incrementally instead of being fully
	buffered in memory first.
**/
private inline final STREAM_CHUNK_SIZE = 65536; // 64k

class TCPSocket implements Socket {
	public final socket:sys.net.Socket;

	public inline function new(socket:sys.net.Socket)
		this.socket = socket;

	public inline function write(data:Bytes)
		socket.output.write(data);

	public function writeInput(input:haxe.io.Input, len:Int) {
		// `socket.output` writes are blocking and complete fully before
		// returning, so the same buffer can safely be reused across chunks.
		final buf = Bytes.alloc(len < STREAM_CHUNK_SIZE ? len : STREAM_CHUNK_SIZE);
		var remaining = len;
		while (remaining > 0) {
			final toRead = remaining > STREAM_CHUNK_SIZE ? STREAM_CHUNK_SIZE : remaining;
			final read = input.readBytes(buf, 0, toRead);
			if (read == 0)
				throw haxe.io.Error.Blocked;
			socket.output.write(read == buf.length ? buf : buf.sub(0, read));
			remaining -= read;
		}
	}

	public inline function close()
		socket.close();
}

#if hl
class UVSocket implements Socket {
	public final socket:hl.uv.Stream;

	final loop:hl.uv.Loop;

	public inline function new(socket:hl.uv.Stream, loop:hl.uv.Loop) {
		this.socket = socket;
		this.loop = loop;
	}

	public inline function write(data:Bytes)
		socket.write(data);

	public function writeInput(input:haxe.io.Input, len:Int) {
		var remaining = len;
		while (remaining > 0) {
			final toRead = remaining > STREAM_CHUNK_SIZE ? STREAM_CHUNK_SIZE : remaining;
			final buf = Bytes.alloc(toRead);
			final read = input.readBytes(buf, 0, toRead);
			if (read == 0)
				throw haxe.io.Error.Blocked;
			var done = false;
			var ok = false;
			socket.write(read == buf.length ? buf : buf.sub(0, read), success -> {
				done = true;
				ok = success;
			});
			while (!done)
				loop.run(Once);
			if (!ok)
				throw new haxe.io.Eof();

			remaining -= read;
		}
	}

	public inline function close()
		socket.close();
}
#end
