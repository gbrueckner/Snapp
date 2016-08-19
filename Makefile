INCS = -I./lib/GBVersionTracking
CFLAGS = -Wall -ObjC -fno-objc-arc -fmodules -O3 $(INCS)

SRC_C = $(wildcard src/*.c)
SRC_OBJC = $(wildcard src/*.m) $(wildcard lib/GBVersionTracking/GBVersionTracking/*.m)
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
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.brueckner.Snapp',0,1,1,NULL,NULL);"

.PHONY: uninstall
uninstall:
	osascript -e 'quit app "Snapp"'
	defaults delete com.brueckner.Snapp
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "delete from access where client='com.brueckner.Snapp';"
