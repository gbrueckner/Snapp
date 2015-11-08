CFLAGS = -Wall -ObjC -fno-objc-arc -fmodules -O3

SRC_C = $(wildcard src/*.c)
SRC_OBJC = $(wildcard src/*.m)
OBJ = $(SRC_C:.c=.o) $(SRC_OBJC:.m=.o)

Snapp.app/Contents/MacOS/Snapp: $(OBJ)
	mkdir -p Snapp.app/Contents/MacOS
	cc -o $@ $^

.PHONY: clean
clean:
	rm -f $(OBJ)
	rm -f Snapp.app/Contents/MacOS/Snapp

.PHONY: install
install:
	cp -r Snapp.app /Applications/
	cp Snapp.app/Contents/Resources/anonymous.Snapp.plist ~/Library/LaunchAgents/
	chmod 0644 ~/Library/LaunchAgents/anonymous.Snapp.plist
	launchctl load ~/Library/LaunchAgents/anonymous.Snapp.plist

.PHONY: uninstall
uninstall:
	launchctl unload ~/Library/LaunchAgents/anonymous.Snapp.plist
	rm -f ~/Library/LaunchAgents/anonymous.Snapp.plist
	osascript -e 'quit app "Snapp"'
	rm -rf /Applications/Snapp.app/
