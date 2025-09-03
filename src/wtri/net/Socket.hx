package wtri.net;

interface Socket {
	function write(data:Bytes):Void;
	function writeInput(input:haxe.io.Input, len:Int):Void;
	function close():Void;
}

class TCPSocket implements Socket {
	public final socket:sys.net.Socket;

	public inline function new(socket:sys.net.Socket)
		this.socket = socket;

	public inline function write(data:Bytes)
		socket.output.write(data);

	public inline function writeInput(input:haxe.io.Input, len:Int) {
		socket.output.writeInput(input, len);
		// socket.output.flush();
		/*
			final chunkSize = 65536; // 64k buffer
			final buf = haxe.io.Bytes.alloc(chunkSize);
			var remaining = len;
			var chunkNum = 0;
			while (remaining > 0) {
				final toRead = remaining > chunkSize ? chunkSize : remaining;
				try {
					final bytesRead = input.readBytes(buf, 0, toRead);
					if (bytesRead == 0)
						break;
					remaining -= bytesRead;
					final startTime = haxe.Timer.stamp();
					Sys.println('TCP Write Chunk #${chunkNum++}: ${bytesRead} bytes. Blocking...');
					if (bytesRead == chunkSize) {
						socket.output.write(buf);
					} else {
						socket.output.write(buf.sub(0, bytesRead));
					}
					// socket.output.flush();
					final duration = haxe.Timer.stamp() - startTime;
					Sys.println('...Unblocked after ${duration} seconds.');
				} catch (e:haxe.io.Eof) {
					break;
				}
			}
		 */
	}

	public inline function close()
		socket.close();
}

#if hl
class UVSocket implements Socket {
	public final socket:hl.uv.Stream;

	public inline function new(socket:hl.uv.Stream)
		this.socket = socket;

	public inline function write(data:Bytes)
		socket.write(data);

	public inline function writeInput(input:haxe.io.Input, len:Int) {
		socket.write(input.read(len));
		// final bufSize = 65536; // 64k buffer
		// var buf = Bytes.alloc(bufSize);
		// var remaining = len;
		// while (remaining > 0) {
		//	try {
		//		final n = input.readBytes(buf, 0, remaining > bufSize ? bufSize : remaining);
		//		if (n == 0)
		//			break;
		//		remaining -= n;
		//		n == bufSize ? socket.write(buf) : socket.write(buf.sub(0, n));
		//	} catch (e:haxe.io.Eof) {
		//		break;
		//	}
		// }
	}

	public inline function close()
		socket.close();
}
#end
