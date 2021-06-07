WTRI
====
Embeddable haxe/sys web server.

[![CI](https://github.com/tong/wtri/actions/workflows/ci.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/ci.yml)


## Build

```sh
git clone https://github.com/tong/wtri.git
cd wtri/
haxelib dev wtri .

haxe build.hxml -neko wtri.n # NekoVM
haxe build.hxml -hl wtri.hl # HashlinkVM
make # HashlinkC
```

## Run

```sh
Usage: wtri [options]

[-host] <name>       : Address to bind
[-port] <number>     : Port to bind
[-path] <path>       : Filesystem root
[--uv] <connections> : Use libuv
[--quiet]            : Disable logging to stdout
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
