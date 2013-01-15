
#
# WTRI
#

BIN = wtri.n
SRC = sys/net/*.hx sys/web/*.hx
HX = haxe -main sys.web.HTTPServer -neko $(BIN) -D haxe3 -D wtri_standalone

all: build

build: $(SRC)
	$(HX) -dce full --no-traces

build-debug: $(SRC)
	$(HX) -debug

clean:
	rm -f $(BIN)
