package wtri.handler;

import sys.thread.Thread;
import wtri.net.WebSocket;

class WebSocketHandler implements wtri.Handler {
	public var path:String;
	public var onconnect:Client->Void;
	public var clients(default, null) = new Array<Client>();

	public function new(path:String, ?onconnect:Client->Void) {
		this.path = path;
		this.onconnect = onconnect;
	}

	public inline function iterator():Iterator<Client>
		return clients.iterator();

	public function handle(req:Request, res:Response):Bool {
		if (req.path != '/$path')
			return false;
		if (req.headers.get(Connection) != 'Upgrade' && req.headers.get(Upgrade) != 'websocket')
			return false;
		final skey = req.headers.get(Sec_WebSocket_Key);
		if (skey == null)
			return false;
		// var sversion = req.headers.get('Sec-WebSocket-Version');
		final key = WebSocket.createKey(skey);
		res.code = SWITCHING_PROTOCOL;
		res.headers.set(Connection, 'Upgrade');
		res.headers.set(Upgrade, 'websocket');
		res.headers.set(Sec_WebSocket_Accept, key);
		res.end();
		switch Type.typeof(res.socket) {
			case TClass(c):
				if (Type.getClassName(c) != 'wtri.net.TCPSocket')
					return false;
			case _:
		}
		final client = createClient(cast(res.socket, TCPSocket).socket);
		if (client == null)
			return false;
		clients.push(client);
		client.read();
		onconnect(client);
		return true;
	}

	public function broadcast(data:Data) {
		for (c in clients)
			c.write(data);
	}

	function createClient(socket:sys.net.Socket):Client {
		return new Client(this, socket);
	}
}

class Client {
	public dynamic function onmessage(message:Bytes) {}

	public dynamic function ondisconnect() {}

	public final handler:WebSocketHandler;
	public final socket:sys.net.Socket;

	var thread:Thread;

	public function new(handler:WebSocketHandler, socket:sys.net.Socket) {
		this.handler = handler;
		this.socket = socket;
	}

	public function read() {
		thread = Thread.create(() -> {
			var sock:sys.net.Socket = Thread.readMessage(true);
			var _onmessage:Bytes->Void = Thread.readMessage(true);
			var _ondisconnect:Void->Void = Thread.readMessage(true);
			var frame:Bytes = null;
			while (true) {
				try {
					frame = WebSocket.readFrame(sock.input);
					// } catch(e:haxe.io.Eof) {
					//     trace(e);
					//     _ondisconnect();
					//     break;
				} catch (e) {
					trace(e);
					_ondisconnect();
					break;
				}
				if (frame != null)
					_onmessage(frame);
			}
		});
		thread.sendMessage(socket);
		thread.sendMessage(s -> {
			onmessage(s);
		});
		thread.sendMessage(() -> {
			close();
		});
	}

	public inline function write(data:Data) {
		WebSocket.writeFrame(socket.output, data);
	}

	public function close() {
		handler.clients.remove(this);
		if (socket != null) {
			try
				socket.close()
			catch (e) {
				trace(e);
			}
		}
		ondisconnect();
	}
}
