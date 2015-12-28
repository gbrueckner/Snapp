/* Copyright 2015 gbrueckner.
 *
 * This file is part of Snapp.
 *
 * Snapp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Snapp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Snapp.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "SNFocusedWindowTracker.h"
#import "AXError+Additions.h"


#pragma mark - SNFocusedWindowTracker private interface


@interface SNFocusedWindowTracker ()

@property id<SNFocusedWindowTrackerDelegate> delegate;
@property AXObserverRef windowObserver;
@property AXUIElementRef focusedApp;

- (void)focusedWindowDidChange:(AXUIElementRef)focusedWindow;

@end


#pragma mark - AXObserverRef callback


void focusedWindowDidChange(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void *contextData) {
    [(SNFocusedWindowTracker *)contextData focusedWindowDidChange:element];
}


#pragma mark - SNFocusedWindowTracker implementation


@implementation SNFocusedWindowTracker


- (instancetype)initWithDelegate:(id<SNFocusedWindowTrackerDelegate>)delegate {

    if ((self = [super init])) {

        self.delegate = delegate;

        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(didActivateApplication:)
                                                                   name:NSWorkspaceDidActivateApplicationNotification
                                                                 object:nil];
    }

    return self;
}


- (void)dealloc {

    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

    if (_focusedApp != NULL) {
        AXObserverRemoveNotification(_windowObserver,
                                     _focusedApp,
                                     kAXFocusedWindowChangedNotification);
        CFRelease(_focusedApp);
    }

    if (_windowObserver != NULL) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
                              AXObserverGetRunLoopSource(_windowObserver),
                              kCFRunLoopDefaultMode);
        CFRelease(_windowObserver);
    }

    self.delegate = nil;
    [super dealloc];
}


- (void)didActivateApplication:(NSNotification *)notification {

    AXError error;

    if (self.windowObserver != NULL || self.focusedApp != NULL) {

        CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
                              AXObserverGetRunLoopSource(self.windowObserver),
                              kCFRunLoopDefaultMode);

        error = AXObserverRemoveNotification(self.windowObserver,
                                             self.focusedApp,
                                             kAXFocusedWindowChangedNotification);

        CFRelease(self.windowObserver);
        CFRelease(self.focusedApp);
    }

    pid_t pid = [[notification.userInfo objectForKey:NSWorkspaceApplicationKey] processIdentifier];
    if (pid == -1) {
        NSLog(@"Could not determine the PID for this application.");
        return;
    }

    self.focusedApp = AXUIElementCreateApplication(pid);

    error = AXObserverCreate(pid, focusedWindowDidChange, &_windowObserver);
    if (error != kAXErrorSuccess) {
        NSLog(@"AXObserverCreate failed (%@).", AXErrorToNSString(error));
        return;
    }

    // In the scenario that the user has focused app A and then starts dragging
    // a window of app B there is a short time span where
    // AXObserverAddNotification fails. However, it is necessary to call this
    // function as soon as possible, because otherwise a drag might not be
    // correctly recognized.
    // This is the purpose of this loop. To prevent Snapp from getting stuck in
    // the loop, the magic value of 10000 attempts is used.
    int attempts = 0;
    do {
        error = AXObserverAddNotification(self.windowObserver,
                                          self.focusedApp,
                                          kAXFocusedWindowChangedNotification,
                                          self);
        attempts++;
    } while (error != kAXErrorSuccess && attempts < 10000);
    if (error != kAXErrorSuccess) {
        NSLog(@"AXObserverAddNotification failed (%@).", AXErrorToNSString(error));
        return;
    }

    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       AXObserverGetRunLoopSource(self.windowObserver),
                       kCFRunLoopDefaultMode);

    // The focusedApp has changed, so update focusedWindow accordingly.
    [self focusedWindowDidChange:NULL];
}


- (void)focusedWindowDidChange:(AXUIElementRef)window {

    if (window == NULL) {
        if (AXUIElementCopyAttributeValue(self.focusedApp,
                                          kAXFocusedWindowAttribute,
                                          (CFTypeRef *) &window) != kAXErrorSuccess) {
            [self performSelector:@selector(focusedWindowDidChange:)
                       withObject:nil
                       afterDelay:0.1];
            return;
        }
    }
    else
        CFRetain(window);

    SNWindow *focusedWindow = [[SNWindow alloc] initWithWindowElement:window];

    [self.delegate focusedWindowDidChange:focusedWindow];

    [focusedWindow release];
    CFRelease(window);
}


@end
