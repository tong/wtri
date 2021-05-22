WTRI
====
Embeddable haxe/sys web server (+library).

[![CI](https://github.com/tong/wtri/actions/workflows/ci.yml/badge.svg)](https://github.com/tong/wtri/actions/workflows/ci.yml)


## Build

```sh
git clone https://github.com/tong/wtri.git
cd wtri/
haxelib dev wtri .
haxe build-hl.hxml
```

## Run

```sh
Usage: hl wtri.hl [options]

[-host] <name>   : Address to bind
[-port] <number> : Port number
[-path] <path>   : Filesystem root path
[--help]         : Print this help
```

## Embed

```hx
new wtri.Server( (req,res) -> {
    Sys.println( req.path );
    res.end( Bytes.ofString('Hello!') );
}).listen( 8080 );
```
See: [Main.hx](src/Main.hx)
