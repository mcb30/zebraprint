LIBS		:= libxml-2.0 libxslt

CFLAGS		+= $(shell pkg-config $(LIBS) --cflags)
LDFLAGS		+= $(shell pkg-config $(LIBS) --libs)

CFLAGS		+= -O3
CFLAGS		+= -W -Wall -Wextra -Werror

all : xmltocpcl

xmltocpcl : xmltocpcl.c Makefile
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@

clean :
	$(RM) xmltocpcl
