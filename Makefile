
#
# wtri - web server
#
# For release version build with: release=true
# Default is debug
#

CPPFLAGS =
SRC = sys/net/ThreadSocketServer.hx sys/net/WebSocketUtil.hx

ifeq (${release},true)
FLAGS = --no-traces -dce full
else
FLAGS = -debug -dce no
endif

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${uname_M},x86_64)
CPPFLAGS += -D HXCPP_M64
endif

all: ws-neko wss-neko

ws-neko: $(SRC) sys/WebServer*.hx
	@mkdir -p bin
	haxe -neko bin/wtri.n -main sys.WebServer $(FLAGS) -D dev_server

wss-neko: $(SRC) sys/WebSocketServer*.hx
	@mkdir -p bin
	haxe -neko bin/wtri-ws.n -main sys.WebSocketServer $(FLAGS) -D dev_server

#ws-cpp: $(SRC) sys/WebServer*.hx
#	haxe -cpp bin/cpp -main sys.WebServer $(FLAGS) $(CPPFLAGS) -D dev_server
#	#TODO mv

#wss-cpp: $(SRC) sys/WebSocketServer*.hx
#	haxe -cpp bin/cpp -main sys.WebSocketServer $(FLAGS) $(CPPFLAGS) -D dev_server
#	#TODO mv

clean:
	rm -rf bin

.PHONY: all ws-neko wss-neko clean
