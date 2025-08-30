# WTRI

Embeddable haxe/sys web server.

## Usage

```hx
new wtri.Server((req,res)-> {
    Sys.println(req.path);
    res.end('Hello!');
}).listen(8080);
```

See: [Wtri.hx](https://github.com/tong/wtri/blob/master/src/Wtri.hx)

## Build

Clone and install dependencies:

```sh
git clone https://github.com/tong/wtri.git
cd wtri/
haxelib install haxelib.json
haxelib dev wtri .
```

Build for various targets:

```sh
haxe wtri.hxml -hl wtri.hl
haxe wtri.hxml -hl out/main.c -D hlgen.makefile=make
haxe wtri.hxml -neko wtri.n
haxe wtri.hxml -cpp cpp
haxe wtri.hxml -python wtri.py
haxe wtri.hxml -lua wtri.lua -D lua-vanilla -D lua-jit
haxe wtri.hxml --jvm wtri.jar
```

## Run

```sh
wtri --help

Usage: wtri [options]

[--host] <name>      : Address to bind
[--port] <number>    : Port to bind
[--root] <path>      : File system root
[--deflate] <level>  : Enable deflate content encoding
[--uv] <connections> : Use libuv (hl)
[--hscript]          : Enable hcript handler
[--quiet]            : Disable logging to stdout
[--help]             : Print this help
```

Run directly as an initialization macro:

```sh
haxe -lib wtri --macro 'Wtri.start(8080)'
```

[![Build](https://github.com/tong/wtri/actions/workflows/build.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/build.yml)
