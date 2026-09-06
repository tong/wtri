package wtri;

class Server {
	public var listening(default, null) = false;
	public var maxConnections(default, null):Int;

	#if hl
	public var uv(default, null):Bool;
	public var loop(default, null):hl.uv.Loop;
	#end

	public var handle:Request->Response->Void;

	public function new(handle:Request->Response->Void)
		this.handle = handle;

	public function listen(port:Int, host = 'localhost', uv = false, maxConnections = 10, connectionTimeout = 15.0):Server {
		#if sys
		this.maxConnections = maxConnections;
		#if hl
		if (this.uv = uv) {
			loop = hl.uv.Loop.getDefault();
			var tcp = new hl.uv.Tcp(loop);
			tcp.bind(new sys.net.Host(host), port);
			tcp.listen(maxConnections, () -> {
				var s = tcp.accept();
				s.readStart(bytes -> {
					try {
						process(new wtri.net.Socket.UVSocket(s, loop), new BytesInput(bytes));
					} catch (e:Dynamic) {
						s.close();
					}
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
			client.setTimeout(connectionTimeout);
			final socket = new wtri.net.Socket.TCPSocket(client);
			try {
				while (process(socket, client.input)) {}
			} catch (e:Dynamic) {}
			try {
				client.close();
			} catch (e:Dynamic) {}
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

	public function process(socket:Socket, ?input:haxe.io.Input):Bool {
		final req = request(socket, input);
		final res = response(req);
		handle(req, res);
		if (!res.finished)
			return false;
		final connection = res.headers.get(Connection);
		return connection != null && connection.toLowerCase() == 'keep-alive';
	}

	public function request(socket:Socket, ?input:haxe.io.Input):Request {
		return new Request(socket, input);
	}

	public function response(req:Request):Response {
		final res = new Response(req);
		final requestedConnection = req.headers.get(Connection);
		final keepAlive = requestedConnection != null ? requestedConnection.toLowerCase() == 'keep-alive' : req.protocol == 'HTTP/1.1';
		res.headers.set(Connection, keepAlive ? 'keep-alive' : 'close');
		return res;
	}
}
