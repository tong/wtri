# WTRI

Embeddable haxe/sys web server.

## Embed

```hx
new wtri.Server((req,res)-> {
    Sys.println(req.path);
    res.end('Hello!');
}).listen(8080);
```

See: [Main.hx](https://github.com/tong/wtri/blob/master/src/Main.hx)

---

## Example server

### Build

```sh
git clone https://github.com/tong/wtri.git
cd wtri/
haxelib dev wtri .

haxe wtri.hxml -hl wtri.hl
haxe wtri.hxml -neko wtri.n
haxe wtri.hxml -cpp cpp
haxe wtri.hxml -python wtri.py
haxe wtri.hxml -lua wtri.lua -D lua-vanilla -D lua-jit
haxe wtri.hxml --jvm wtri.jar
make # HashlinkC
```

### Run

```sh
Usage: wtri [options]

[--host] <name>      : Address to bind
[--port] <number>    : Port to bind
[--root] <path>      : Filesystem root
[--deflate] <level>  : Deflate
[--uv] <connections> : Use libuv
[--quiet]            : Disable logging to stdout
[--help]             : Print this help
```

[![Build](https://github.com/tong/wtri/actions/workflows/build.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/build.yml)
