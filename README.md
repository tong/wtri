WTRI
====
Embeddable haxe/sys web server.

[![Build](https://github.com/tong/wtri/actions/workflows/build.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/build.yml)

## Build

```sh
git clone https://github.com/tong/wtri.git
cd wtri/
haxelib dev wtri .

haxe build.hxml -neko wtri.n # Neko
haxe build.hxml -hl wtri.hl # Hashlink
make # HashlinkC
```

## Run

```sh
Usage: wtri [options]

[--host] <name>      : Address to bind
[--port] <number>    : Port to bind
[--root] <path>      : Filesystem root
[--uv] <connections> : Use libuv (hashlink only)
[--quiet]            : Disable logging
[--help]             : Print this help
```

## Embed

```hx
new wtri.Server( (req,res) -> {
    Sys.println( req.path );
    res.end( 'Hello!' );
}).listen( 8080 );
```
See: [Main.hx](Main.hx)
