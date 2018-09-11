CUPS_DATADIR	?= /usr/share/cups
CUPS_FILTERDIR	?= /usr/lib/cups/filter

all :
	$(MAKE) -C cups

test : all
	$(MAKE) -C xml test

install : all
	mkdir -p $(CUPS_DATADIR)/zebraprint
	install -m 644 xml/cpcl.xsd xml/cpcl.xslt $(CUPS_DATADIR)/zebraprint/
	install -m 755 cups/xmltocpcl $(CUPS_FILTERDIR)/
	install -m 644 cups/zebraprint.types cups/zebraprint.convs \
		$(CUPS_DATADIR)/mime/

clean :
	$(MAKE) -C cups clean
