all :

test :
	valgrind -q --leak-check=full --error-exitcode=1 ../cups/xmltocpcl \
		< tests/hello.xml > /dev/null
	$(MAKE) -C tests test
