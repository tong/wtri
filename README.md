WTRI
====
Haxe/sys web server (+library).

[![CI](https://github.com/tong/wtri/actions/workflows/ci.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/ci.yml)

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