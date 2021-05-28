CFLAGS = -Os -std=c11 -msse2 -mfpmath=sse -m64 -fPIC -pthread -fno-omit-frame-pointer -D LIBHL_EXPORTS
HDLL = /usr/local/lib/uv.hdll

SRC = $(shell find src/ -type f -name '*.hx')

all: wtri

out/main.c: $(SRC)
	haxe build.hxml -hl $@

wtri: out/main.c
	${CC} -o $@ -Iout out/main.c ${CFLAGS} -lhl -luv ${HDLL}

clean:
	rm -rf out/ 
	rm -f wtri wtri.*

.PHONY: all clean
