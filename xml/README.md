CPCL/XML
========

CPCL/XML is a mapping of the [Comtec Printer Control Language
(CPCL)](https://www.zebra.com/us/en/support-downloads/knowledge-articles/cpcl-manual-for-zebra-mobile-printers.html)
to XML, designed to facilitate the generation of CPCL using existing
XML-based toolchains.

A CPCL/XML document has MIME type `application/x-cpcl+xml` and is
formally defined using an [XML schema](cpcl.xsd).  There is an [XML
stylesheet](cpcl.xslt) that can be used to transform a CPCL/XML
document into raw CPCL.

The [tests](tests/) subdirectory contains examples from the CPCL
Programming Manual in both CPCL and CPCL/XML formats.
