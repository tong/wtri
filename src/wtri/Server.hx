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

	public function listen(port:Int, host = 'localhost', uv = false, maxConnections = 10, connectionTimeout = 15.0, threads = 1):Server {
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
		#if target.threaded
		if (threads > 1) {
			acceptThreaded(server, threads, connectionTimeout);
			server.close();
			return this;
		}
		#end
		while (listening) {
			var client = server.accept();
			client.setTimeout(connectionTimeout);
			client.setFastSend(true);
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

	#if target.threaded
	/**
		Accepts connections on the calling thread and spreads them round-robin over
		`threads` workers. Each worker multiplexes its connections with `select`
		(like hxvid's `RealtimeServer`), so idle keep-alive connections don't tie
		up a thread; a request is only processed once its socket is readable.
		`handle` is called concurrently and must be thread-safe.
	**/
	function acceptThreaded(server:sys.net.Socket, threads:Int, timeout:Float) {
		final workers = [for (_ in 0...threads) new Worker(this, timeout)];
		for (w in workers)
			sys.thread.Thread.create(w.run);
		var next = 0;
		while (listening) {
			final client = server.accept();
			client.setTimeout(timeout);
			client.setFastSend(true);
			workers[next++ % threads].add(client);
		}
		for (w in workers)
			w.stop();
	}
	#end

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

#if target.threaded
private class Worker {
	/** Max time `select` waits before the worker checks for new connections and idle timeouts. **/
	static inline final POLL = 0.05;

	final server:Server;
	final timeout:Float;
	final queue = new sys.thread.Deque<sys.net.Socket>();
	final socks:Array<sys.net.Socket> = [];
	var running = true;

	public function new(server:Server, timeout:Float) {
		this.server = server;
		this.timeout = timeout;
	}

	public function add(s:sys.net.Socket)
		queue.add(s);

	public function stop() {
		running = false;
		queue.add(null);
	}

	public function run() {
		while (running) {
			// block only while there is nothing to select on
			var s = queue.pop(socks.length == 0);
			while (s != null) {
				s.custom = Sys.time();
				socks.push(s);
				s = queue.pop(false);
			}
			if (socks.length == 0)
				continue;
			final ready = try sys.net.Socket.select(socks, null, null, POLL).read catch (e:Dynamic) [];
			for (s in ready) {
				final keep = try server.process(new wtri.net.Socket.TCPSocket(s), s.input) catch (e:Dynamic) false;
				if (keep)
					s.custom = Sys.time();
				else
					drop(s);
			}
			final now = Sys.time();
			for (s in socks.copy())
				if (now - (s.custom : Float) > timeout)
					drop(s);
		}
		for (s in socks.copy())
			drop(s);
	}

	function drop(s:sys.net.Socket) {
		socks.remove(s);
		try
			s.close()
		catch (e:Dynamic) {}
	}
}
#end
