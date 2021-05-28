CFLAGS = -O3 -std=c11
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
