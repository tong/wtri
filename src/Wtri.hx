import wtri.net.Socket;

var server(default, null):wtri.Server;
var startTime = Sys.time();

#if !eval
private function main() {
	var host = "localhost";
	var port = 8080;
	var root:String = null;
	var quiet = false;
	var uv = false;
	var deflate = 0;
	var scripting = false;
	var maxConnections = 20;

	var usage:String = null;
	var argHandler = hxargs.Args.generate([@doc("Address to bind")
		["--host"] => (name:String) -> host = name, @doc("Port to bind")
		["--port"] => (number:Int) -> {
			if (number < 1 || number > 65535)
				exit(1, 'Port number out of range');
			port = number;
		}, @doc("File system root")
		["--root"] => (path:String) -> {
			if (!FileSystem.exists(path) || !FileSystem.isDirectory(path))
				exit(1, 'Root path not found');
			root = path;
		},
		@doc("Enable deflate content encoding")
		["--deflate"] => (level:Int) -> deflate = level,
		#if hl
		@doc("Use libuv (hl)") ["--uv"] => (connections:Int) -> {
			maxConnections = connections;
			uv = true;
		},
		#end
		#if hscript
		@doc("Enable hcript handler") ["--hscript"] => () -> scripting = true,
		#end
		@doc("Disable logging to stdout")
		["--quiet"] => () -> quiet = true, @doc("Print this help")
		["--help"] => () -> exit(usage),
		_ => arg -> exit(1, 'Unknown argument [$arg]\n')
	]);
	usage = 'Usage: wtri [options]\n\n' + argHandler.getDoc();
	argHandler.parse(Sys.args());

	start(host, port, root, deflate, scripting, quiet, uv, maxConnections);
}
#end // !eval
function start(host = "localhost", port = 8080, ?root:String, deflate = 0, scripting = false, quiet = false, uv = false, maxConnections = 20) {
	if (root == null)
		root = Sys.getCwd();
	else {
		if (!FileSystem.exists(root))
			exit(1, 'root not found: $root');
	}

	wtri.Response.defaultHeaders.set("server", "wtri");

	final handlers:Array<wtri.Handler> = [];

	#if hscript
	if (scripting) {
		final hs = new wtri.handler.HScriptHandler(root);
		hs.interp.variables.set("Bytes", Bytes);
		hs.interp.variables.set("Date", Date);
		hs.interp.variables.set("Math", Math);
		hs.interp.variables.set("FileSystem", FileSystem);
		// hs.interp.variables.set("File", File);
		handlers.push(hs);
	}
	#end

	/*
		var wsHandler = new wtri.handler.WebSocketHandler();
		wsHandler.onconnect = client -> {
			trace("Websocket client connected",wsHandler.clients.length, client.socket.peer().host );
			client.onmessage = m -> {
				trace("Websocket client message: "+m);
				if( m != null ) {
					var str = m.toString();
					switch str {
					case 'quit':
						client.close();
					case _:
						wsHandler.broadcast( m );
					}
				}
			}
			client.ondisconnect = () -> {
				trace("Websocket client disconnected",wsHandler.clients.length);
			}
			client.write("Welcome!");
		}
	 */

	// wsHandler,
	handlers.push(new wtri.handler.FileSystemHandler(root, true));

	if (deflate > 0) {
		handlers.push(new wtri.handler.ContentEncoding([
			"deflate" => b -> {
				return haxe.zip.Compress.run(b, deflate);
				// return format.tools.Deflate.run(b);
			}
		]));
	}

	server = new wtri.Server((req, res) -> {
		for (h in handlers)
			h.handle(req, res);
		if (!res.finished)
			res.end();
		if (!quiet) {
			var info = '${req.method} - ${res.code} - ${req.path}';
			if (Std.isOfType(req.socket, TCPSocket)) {
				final tcp:wtri.net.Socket.TCPSocket = cast req.socket;
				final peer = tcp.socket.peer();
				info = '${peer.host} - $info';
			}
			log(info);
		}
	});
	log('Starting server http://$host:$port');
	server.listen(port, host, uv, maxConnections);
}

function log(str:String) {
	Sys.println('${Date.now().toString()} - $str');
}

function exit(code = 0, ?msg:String) {
	if (msg != null) {
		switch code {
			case 0:
				Sys.stdout().writeString('$msg\n');
			case _:
				Sys.stderr().writeString('$msg\n');
		}
	}
	Sys.exit(code);
}
