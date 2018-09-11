CFLAGS		+= $(shell xml2-config --cflags)
LDFLAGS		+= $(shell xml2-config --libs)

CFLAGS		+= $(shell xslt-config --cflags)
LDFLAGS		+= $(shell xslt-config --libs)

CFLAGS		+= -O3
CFLAGS		+= -W -Wall -Wextra -Werror

all : xmltocpcl

xmltocpcl : xmltocpcl.c Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

clean :
	$(RM) xmltocpcl
