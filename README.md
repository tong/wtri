WTRI
====
Embeddable haxe/sys web server.

[![Build](https://github.com/tong/wtri/actions/workflows/build.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/build.yml)

## Build

```sh
git clone https://github.com/tong/wtri.git
cd wtri/
haxelib dev wtri .

make # HashlinkC
haxe wtri.hxml -hl wtri.hl
haxe wtri.hxml -neko wtri.n
haxe wtri.hxml -python wtri.py
haxe wtri.hxml -lua wtri.lua -D lua-vanilla -D lua-jit
haxe wtri.hxml --jvm wtri.jar
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
See: [Main.hx](https://github.com/tong/wtri/blob/master/src/Main.hx)

