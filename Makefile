CFLAGS = -Wall -ObjC -fno-objc-arc -fmodules -O3

SRC_C = $(wildcard src/*.c)
SRC_OBJC = $(wildcard src/*.m)
OBJ = $(SRC_C:.c=.o) $(SRC_OBJC:.m=.o)

Snapp.app/Contents/MacOS/Snapp: $(OBJ)
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
	launchctl load -w  ~/Library/LaunchAgents/anonymous.Snapp.plist

.PHONY: uninstall
uninstall:
	osascript -e 'quit app "Snapp"'
	launchctl unload -w ~/Library/LaunchAgents/anonymous.Snapp.plist
	rm -f ~/Library/LaunchAgents/anonymous.Snapp.plist
	rm -rf /Applications/Snapp.app/
