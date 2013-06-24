
#
# wtris
#
# For debug build set: DEBUG=true
#

SRC = sys/*.hx sys/net/*.hx
CPPFLAGS =
DEBUG = false

ifeq (${DEBUG},true)
FLAGS = -debug -dce no
else
FLAGS = --no-traces -dce full
endif

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${uname_M},x86_64)
CPPFLAGS += -D HXCPP_M64
endif

HX = haxe -D dev_server \
	-resource tpl/index.html@index \
	-resource tpl/config.html@config \
	-resource tpl/404.html@404

all: dev-server

dev-server: $(SRC)
	$(HX) -neko wtri.n -main wtri.Server $(FLAGS)

dev-server-cpp: $(SRC)
	$(HX) -cpp build -main wtri.Server $(FLAGS) $(CPPFLAGS)

#websocketserver-cpp: $(SRC)
#	$(HX) -cpp bin/cpp -main haxe.WebSocketServer $(FLAGS) $(CPPFLAGS)

#websocketserver-neko: $(SRC)
#	@mkdir -p bin
#	$(HX) -neko bin/wtri-ws.n -main haxe.WebSocketServer $(FLAGS)

clean:
	rm -rf bin

.PHONY: all dev-server dev-server-cpp clean
