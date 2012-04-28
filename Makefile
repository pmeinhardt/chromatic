
DST=/usr/local/bin/chromatic

install: chromatic.sh
	cp $< $(DST)
	chmod a+x $(DST)
