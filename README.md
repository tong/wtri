WTRI
====
Haxe/sys web server (+library).


## Library

```hx
var server = new wtri.Server( (req,res) -> {
    res.writeHead( OK ).end( 'Hello!' );
}).listen( port, host, uv );
```


## Usage

```sh
Usage: wtri [options]

[-host] <name>   : Address to bind
[-port] <number> : Port number
[-root] <path>   : Filesystem root path
[--uv]           : Use libuv
[--help]         : Print this help
```