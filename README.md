Zebra printer support for Linux
===============================

Zebra [printers](https://www.zebra.com/gb/en/products/printers.html)
are supported by the [CUPS](https://www.cups.org) printing system but
only as raster image devices.  This means that documents to be printed
are sent to the printer as a large raster (bitmap) image.  On some
Zebra printers, this can result in a delay of around 80 seconds before
the label is printed.

A more efficient method is to use the [Comtec Printer Control Language
(CPCL)](https://www.zebra.com/us/en/support-downloads/knowledge-articles/cpcl-manual-for-zebra-mobile-printers.html).
This is a page description language (analogous to PostScript) that can
be used to describe the page using built-in primitives for text,
barcodes, graphics, etc.  An example page in CPCL could be:

    ! 0 200 200 210 1
    TEXT 4 0 30 40 Hello World
    FORM
    PRINT

This package defines an XML mapping of CPCL: [CPCL/XML](xml/) (with
MIME type `application/x-cpcl+xml`), allowing CPCL documents to be
constructed using XML-based toolchains.  The same example page in
CPCL/XML would be:

    <?xml version="1.0" encoding="utf-8"?>
    <cpcl xmlns="http://www.fensystems.co.uk/xmlns/cpcl" height="210">
      <text x="30" y="40">Hello World</text>
      <form/>
    </cpcl>

Installing this package will allow you to print CPCL or CPCL/XML
documents directly to your Zebra printer via CUPS.
