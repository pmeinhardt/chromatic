DESTINATION=/usr/local/bin/chromatic

install: chromatic
	cp -i $< $(DESTINATION) && chmod a+x $(DESTINATION)
