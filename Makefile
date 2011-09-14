
DST=/usr/local/bin

install: chromatic.sh
		cp $< $(DST)/$<
		chmod a+x $(DST)/$<
