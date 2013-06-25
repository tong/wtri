
#
# wtris
#
# For debug build set: DEBUG=true
#

DEBUG = false
INSTALL_DIR = /usr/lib/wtri

SRC = src/sys/*.hx src/sys/net/*.hx src/wtri/*.hx src/tpl/*.html
CPPFLAGS =

ifeq (${DEBUG},true)
FLAGS = -debug -dce no
else
FLAGS = --no-traces -dce full
endif

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${uname_M},x86_64)
CPPFLAGS += -D HXCPP_M64
endif

HX = haxe -D dev_server -cp src \
	-resource tpl/index.html@index \
	-resource tpl/error.html@error

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

install: clean dev-server
	mkdir -p $(INSTALL_DIR)
	cp wtri.n $(INSTALL_DIR)
	cp -r lib/ $(INSTALL_DIR)
	cp data/wtri.sh /usr/bin/wtri
	chmod +x /usr/bin/wtri

uninstall:
	rm -rf $(INSTALL_DIR)

clean:
	rm -rf build
	rm -f wtri.n

.PHONY: all dev-server dev-server-cpp clean
