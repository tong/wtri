
#
# WTRI
#

BIN = wtri.n
SRC = sys/net/*.hx sys/web/*.hx
HX = haxe -main sys.web.HTTPServer -D haxe3 -D wtri_standalone

all: build

build-neko: $(SRC)
	$(HX) -neko $(BIN) -dce full --no-traces

build-debug: $(SRC)
	$(HX) -neko $(BIN) -debug

build-haxelib: build-neko
	cp $(BIN) run.n

build-exe: build-neko
	nekotools boot $(BIN)

build: build-neko

clean:
	rm -f $(BIN) run.n

