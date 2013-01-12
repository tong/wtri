
#
# WTRI
#

SRC = Makefile sys/net/* sys/web/*
SERVER = wtri.n
HX = haxe -main sys.web.HTTPServer -D haxe3 #--dce full #--no-traces

$(SERVER): $(SRC)
	$(HX) -neko $@ -D wtri_standalone
server: $(SERVER)

clean:
	rm -f $(SERVER)
