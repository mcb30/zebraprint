#define DATADIR_ENV "CUPS_DATADIR"
#define DATADIR_SUBDIR "zebraprint"
#define XSLT_FILENAME "cpcl.xslt"
#define XSD_FILENAME "cpcl.xsd"

#define _GNU_SOURCE
#define LIBXML_SCHEMAS_ENABLED
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <libxml/xmlschemastypes.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>

/*
 * Report parsing issue
 */
static void report_issue ( const char *level, const char *msg, va_list args ) {
	static int start = 1;
	va_list tmp;
	char *buf;
	char *pos;
	char *nl;

	/* Format message to temporary buffer */
	va_copy ( tmp, args );
	if ( vasprintf ( &buf, msg, tmp ) < 0 ) {
		va_end ( tmp );
		fprintf ( stderr, "ERROR: Out of memory printing error "
			  "message\n" );
		vfprintf ( stderr, msg, args );
		fprintf ( stderr, "\n" );
		return;
	}
	va_end ( tmp );

	/* Print message, prefixing each line with the level */
	for ( pos = buf ; ; pos = ( nl + 1 ) ) {
		nl = strchr ( pos, '\n' );
		if ( nl )
			*nl = '\0';
		if ( start && ( strlen ( pos ) + 0 ) ) {
			fprintf ( stderr, "%s: ", level );
			start = 0;
		}
		if ( nl ) {
			fprintf ( stderr, "%s\n", pos );
			pos = ( nl + 1 );
			start = 1;
		} else {
			fprintf ( stderr, "%s", pos );
			break;
		}
	}

	/* Free temporary buffer */
	free ( buf );
}

/*
 * Report parsing error
 */
static void XMLCDECL report_error ( void *ctx, const char *msg, ... ) {
	va_list args;

	( void ) ctx;
	va_start ( args, msg );
	report_issue ( "ERROR", msg, args );
	va_end ( args );
}

/*
 * Report parsing warning
 */
static void XMLCDECL report_warning ( void *ctx, const char *msg, ... ) {
	va_list args;

	( void ) ctx;
	va_start ( args, msg );
	report_issue ( "WARN", msg, args );
	va_end ( args );
}

/*
 * Validate document
 */
static int validate ( xmlDocPtr doc, const char *dirname ) {
	xmlSchemaParserCtxtPtr parser;
	xmlSchemaValidCtxtPtr valid;
	xmlSchemaPtr schema;
	char *filename;
	int ret = -1;

	/* Construct filename */
	if ( asprintf ( &filename, "%s/%s", ( dirname ? dirname : "." ),
			XSD_FILENAME ) < 0 )
		goto err_alloc_filename;

	/* Create parser context */
	parser = xmlSchemaNewParserCtxt ( filename );
	if ( ! parser )
		goto err_alloc_parser;

	/* Parse schema */
	xmlSchemaSetParserErrors ( parser, report_error, report_warning, NULL );
	schema = xmlSchemaParse ( parser );
	if ( ! schema )
		goto err_parse_schema;

	/* Create validation context */
	valid = xmlSchemaNewValidCtxt ( schema );
	if ( ! valid )
		goto err_alloc_valid;

	/* Validate document */
	xmlSchemaSetValidErrors ( valid, report_error, report_warning, NULL );
	ret = xmlSchemaValidateDoc ( valid, doc );

	xmlSchemaFreeValidCtxt ( valid );
 err_alloc_valid:
	xmlSchemaFree ( schema );
 err_parse_schema:
	xmlSchemaFreeParserCtxt ( parser );
 err_alloc_parser:
	free ( filename );
 err_alloc_filename:
	return ret;
}

/*
 * Convert document
 */
static int convert ( xmlDocPtr doc, const char *dirname ) {
	const char *params[] = { NULL };
	xsltStylesheetPtr style;
	xmlDocPtr out;
	char *filename;
	int ret = -1;

	/* Construct filename */
	if ( asprintf ( &filename, "%s/%s", ( dirname ? dirname : "." ),
			XSLT_FILENAME ) < 0 )
		goto err_alloc_filename;

	/* Parse stylesheet */
	xsltSetGenericErrorFunc ( NULL, report_error );
	style = xsltParseStylesheetFile ( ( const xmlChar * ) filename );
	if ( ! style )
		goto err_parse_style;

	/* Apply stylesheet */
	out = xsltApplyStylesheet ( style, doc, params );
	if ( ! out )
		goto err_apply;

	/* Output result */
	xsltSaveResultToFile ( stdout, out, style );

	/* Success */
	ret = 0;

	xmlFreeDoc ( out );
 err_apply:
	xsltFreeStylesheet ( style );
 err_parse_style:
	free ( filename );
 err_alloc_filename:
	return ret;
}

/*
 * Main program
 */
int main ( int argc, char **argv ) {
	char *docname;
	char *datadir;
	char *zebradir;
	xmlDocPtr doc;
	int ret = 1;

	/* Identify document source */
	if ( argc > 6 ) {
		docname = argv[6];
	} else {
		docname = NULL;
	}

	/* Parse document */
	xmlSetGenericErrorFunc ( NULL, report_error );
	if ( docname ) {
		doc = xmlReadFile ( docname, NULL, 0 );
	} else {
		doc = xmlReadFd ( 0, "-", NULL, 0 );
	}
	if ( ! doc )
		goto err_doc;

	/* Identify our data directory */
	datadir = getenv ( DATADIR_ENV );
	if ( datadir ) {
		if ( asprintf ( &zebradir, "%s/%s", datadir,
				DATADIR_SUBDIR ) < 0 )
			goto err_alloc_zebradir;
	} else {
		zebradir = NULL;
	}

	/* Validate document */
	if ( validate ( doc, zebradir ) != 0 )
		goto err_validate;

	/* Convert document */
	if ( convert ( doc, zebradir ) != 0 )
		goto err_convert;

	/* Success */
	ret = 0;

 err_convert:
 err_validate:
	free ( zebradir );
 err_alloc_zebradir:
	xmlFreeDoc ( doc );
 err_doc:
	xmlSchemaCleanupTypes();
	xsltCleanupGlobals();
	xmlCleanupParser();
	return ( ret ? 1 : 0 );
}
