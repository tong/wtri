package wtri;

class Server {
	public var listening(default, null) = false;
	public var maxConnections(default, null):Int;
	public var handle:Request->Response->Void;

	#if (hl && libuv)
	public var uv(default, null):Bool;
	public var loop(default, null):hl.uv.Loop;
	#end

	public function new(handle:Request->Response->Void) {
		this.handle = handle;
	}

	public function listen(port:Int, host = 'localhost', uv = false, maxConnections = 10):Server {
		#if sys
		this.maxConnections = maxConnections;
		#if (hl && libuv)
		if (this.uv = uv) {
			loop = hl.uv.Loop.getDefault();
			var tcp = new hl.uv.Tcp(loop);
			tcp.bind(new sys.net.Host(host), port);
			tcp.listen(maxConnections, () -> {
				var s = tcp.accept();
				s.readStart(bytes -> {
					inline process(new wtri.net.Socket.UVSocket(s), new BytesInput(bytes));
				});
			});
			return this;
		}
		#end
		final server = new sys.net.Socket();
		server.bind(new sys.net.Host(host), port);
		server.listen(maxConnections);
		listening = true;
		while (listening) {
			var client = server.accept();
			inline process(new wtri.net.Socket.TCPSocket(client), client.input);
		}
		server.close();
		#end
		return this;
	}

	public function stop() {
		if (listening) {
			listening = false;
			#if (hl && libuv)
			loop.stop();
			#end
		}
	}

	public function process(socket:Socket, ?input:haxe.io.Input) {
		final req = new Request(socket, input);
		final res = createResponse(req);
		handle(req, res);
		switch res.headers.get(Connection) {
			case null, 'close':
				socket.close();
		}
	}

	function createResponse(req:Request) {
		final res = new Response(req);
		if (req.headers.get(Connection) == 'keep-alive') {
			res.headers.set(Connection, 'close');
		}
		return res;
	}
}
