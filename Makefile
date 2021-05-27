CFLAGS = -O3 -std=c11
HDLL = /usr/local/lib/fmt.hdll /usr/local/lib/uv.hdll

SRC = $(shell find src/ -type f -name '*.hx')
SRC_HL = /home/tong/src/hashlink/libs/fmt/

all: wtri

out/main.c: $(SRC)
	haxe build.hxml -hl $@

wtri: out/main.c
	${CC} -o $@ -Iout out/main.c ${CFLAGS} -lhl -luv

clean:
	rm -rf out/ 
	rm -f wtri wtri.*

.PHONY: all clean
