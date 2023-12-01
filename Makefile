CFLAGS = -O3 -Wall -std=c11 -msse2 -mfpmath=sse -m64 -fPIC -pthread -fno-omit-frame-pointer -D LIBHL_EXPORTS
INCLUDE = -Iout -I/usr/local/include
LFLAGS = -L. -lhl -L/usr/local/lib
SRC := $(shell find src/ -type f -name '*.hx')
HDLL = /usr/local/lib/fmt.hdll /usr/local/lib/uv.hdll
#LIBFLAGS = 

all: wtri

out/main.c: $(SRC) wtri.hxml
	haxe wtri.hxml -hl $@

wtri: out/main.c
	${CC} -o $@ out/main.c ${CFLAGS} ${INCLUDE} -lhl -luv ${HDLL}

# wtri.hdll: lib/websocket.c
# 	${CC} -o $@ lib/websocket.c -shared ${CFLAGS} ${LFLAGS}

.c.o :
	${CC} ${CFLAGS} -o $@ -c $<

clean:
	rm -rf out/ 
	rm -f wtri wtri.hl

.PHONY: all clean

