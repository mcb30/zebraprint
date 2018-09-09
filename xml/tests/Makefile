ECHO		?= echo
XSLTPROC	?= xsltproc
XSLT		:= ../cpcl.xslt

XMLS		:= $(wildcard *.xml)
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

%.test : %.test.xslt
	$(Q)

%.test.xslt : %.xml
	$(QM)$(ECHO) "  [XSLT] $<"
	$(Q)$(XSLTPROC) $(XSLT) $< | diff -u - $(basename $(basename $<)).cpcl

.PHONY : %.test.xslt
