
#
# wtri - web server
#
# For debug version build with: DEBUG=true
#

SRC = sys/*.hx sys/net/*.hx
CPPFLAGS =
DEBUG = true

ifeq (${DEBUG},true)
FLAGS = -debug -dce no
else
FLAGS = --no-traces -dce full
endif

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${uname_M},x86_64)
CPPFLAGS += -D HXCPP_M64
endif


all: webserver-neko


webserver-cpp: $(SRC)
	haxe -cpp bin/cpp -main haxe.WebServer $(FLAGS) $(CPPFLAGS) -D dev_server

webserver-neko: $(SRC)
	@mkdir -p bin
	haxe -neko bin/wtri.n -main haxe.WebServer $(FLAGS) -D dev_server


websocketserver-cpp: $(SRC)
	haxe -cpp bin/cpp -main haxe.WebSocketServer $(FLAGS) $(CPPFLAGS) -D dev_server

websocketserver-neko: $(SRC)
	@mkdir -p bin
	haxe -neko bin/wtri-ws.n -main haxe.WebSocketServer $(FLAGS) -D dev_server


clean:
	rm -rf bin


.PHONY: all webserver-cpp webserver-neko websocketserver-cpp websocketserver-neko clean
