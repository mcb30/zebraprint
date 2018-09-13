ECHO		?= echo
XMLLINT		?= xmllint
XSLTPROC	?= xsltproc

XSD		:= ../cpcl.xsd
XSLT		:= ../cpcl.xslt

CPCLS		:= $(wildcard *.cpcl)
XMLS		:= $(patsubst %.cpcl,%.xml,$(CPCLS)) $(wildcard *.xml)
TESTS		:= $(patsubst %.xml,%.test,$(XMLS))

ifeq ($(V),1)
Q :=
QM := @\#
else
Q := @
QM := @
endif

all : test

test : $(TESTS)

%.test : %.test.xsd %.test.xslt
	$(Q)

%.test.xsd : %.xml
	$(QM)$(ECHO) "  [XSD] $<"
	$(Q)$(XMLLINT) --noout --schema $(XSD) $< 2>/dev/null || \
		$(XMLLINT) --schema $(XSD) $<

%.test.xslt : %.xml
	$(QM)$(ECHO) "  [XSLT] $<"
	$(Q)$(XSLTPROC) $(XSLT) $< | diff -u - $(basename $(basename $<)).cpcl

.PHONY : %.test.xslt
