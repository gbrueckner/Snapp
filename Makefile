CFLAGS = -Wall -ObjC -fno-objc-arc -fmodules -O3

SRC_C = $(wildcard src/*.c)
SRC_OBJC = $(wildcard src/*.m)
OBJ = $(SRC_C:.c=.o) $(SRC_OBJC:.m=.o)

Snapp.app/Contents/MacOS/Snapp: $(OBJ)
	mkdir -p Snapp.app/Contents/MacOS
	cc -o $@ $^
	mkdir -p Snapp.app/Contents/Library/LoginItems/SnappHelper.app/Contents/MacOS
	cc $(CFLAGS) -o Snapp.app/Contents/Library/LoginItems/SnappHelper.app/Contents/MacOS/SnappHelper src/SnappHelper/SnappHelper.m

.PHONY: clean
clean:
	rm -f $(OBJ)
	rm -f Snapp.app/Contents/MacOS/Snapp
	rm -f Snapp.app/Contents/Library/LoginItems/SnappHelper.app/Contents/MacOS/SnappHelper

.PHONY: install
install:
	cp -r Snapp.app /Applications/

.PHONY: uninstall
uninstall:
	osascript -e 'quit app "Snapp"'
	rm -rf /Applications/Snapp.app/
