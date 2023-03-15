CFLAGS = -O3 -Wall -std=c11 -msse2 -mfpmath=sse -m64 -fPIC -pthread -fno-omit-frame-pointer -D LIBHL_EXPORTS
INCLUDE = -Iout -I/usr/local/include
LFLAGS = -lhl
SRC := $(shell find src/ -type f -name '*.hx')
#SRC_C := lib/websocket.c /home/tong/src/hashlink/src/std/*.c
HDLL = /usr/local/lib/fmt.hdll /usr/local/lib/uv.hdll
#LIBFLAGS = 

all: build

build: wtri

out/main.c: $(SRC) wtri.hxml
	haxe wtri.hxml -hl $@

wtri: out/main.c
	${CC} -o $@ out/main.c ${CFLAGS} ${INCLUDE} -lhl -luv ${HDLL}

# wtri.hdll: lib/websocket.c
# 	${CC} -o $@ lib/websocket.c -shared ${CFLAGS} ${LFLAGS}

clean:
	rm -rf out/ 
	rm -f wtri wtri.*

.PHONY: all build clean

