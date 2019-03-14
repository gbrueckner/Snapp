/* Copyright 2015-2019 gbrueckner.
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
#import "CGWindow+Additions.h"
#import "SNLog.h"


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

    if (self.windowObserver != NULL && self.focusedApp != NULL) {

        CFRunLoopSourceRef runLoopSource = AXObserverGetRunLoopSource(self.windowObserver);
        if (runLoopSource != NULL)
            CFRunLoopSourceInvalidate(runLoopSource);

        error = AXObserverRemoveNotification(self.windowObserver,
                                             self.focusedApp,
                                             kAXFocusedWindowChangedNotification);

        CFRelease(self.windowObserver);
        CFRelease(self.focusedApp);
    }

    pid_t pid = [[notification.userInfo objectForKey:NSWorkspaceApplicationKey] processIdentifier];
    if (pid == -1)
        return;

    self.focusedApp = AXUIElementCreateApplication(pid);

    error = AXObserverCreate(pid, focusedWindowDidChange, &_windowObserver);
    if (error != kAXErrorSuccess) {
        SNLog(@"AXObserverCreate failed (%@).", AXErrorToNSString(error));
        return;
    }

    // In the scenario that the user has focused app A and then starts dragging
    // a window of app B there is a short time span where
    // AXObserverAddNotification fails. However, it is necessary to call this
    // function as soon as possible, because otherwise a drag might not be
    // correctly recognized.
    // This is the purpose of this block. To prevent Snapp from getting stuck in
    // the block, the magic value of 100 attempts is used.

    __block int attempts = 100;

    void (^__block block)() = [^{

        AXError error = AXObserverAddNotification(self.windowObserver,
                                                  self.focusedApp,
                                                  kAXFocusedWindowChangedNotification,
                                                  self);

        if (error == kAXErrorSuccess) {
            CFRunLoopAddSource(CFRunLoopGetCurrent(),
                               AXObserverGetRunLoopSource(self.windowObserver),
                               kCFRunLoopDefaultMode);

            AXUIElementRef window;
            if (AXUIElementCopyAttributeValue(self.focusedApp,
                                              kAXFocusedWindowAttribute,
                                              (CFTypeRef *) &window) == kAXErrorSuccess) {
                // The focusedApp has changed, so update focusedWindow accordingly.
                [self focusedWindowDidChange:window];
                CFRelease(window);
            }

            [block release];
        }
        else if (attempts-- > 0)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 50),
                           dispatch_get_main_queue(),
                           block);
        else
            SNLog(@"AXObserverAddNotification failed (%@), giving up.", AXErrorToNSString(error));

    } copy];

    block();
}


- (void)focusedWindowDidChange:(AXUIElementRef)window {

    CGEventRef event = CGEventCreate(NULL);
    CGPoint location = CGEventGetLocation(event);
    CFRelease(event);

    CGWindowID windowID = CGWindowWithInfo(window, location);

    SNWindow *newWindow = nil;
    if (windowID != kCGNullWindowID)
        newWindow = [SNWindow windowWithID:windowID
                                   element:window];
    else
        SNLog(@"CGWindowWithInfo() failed.");

    [self.delegate focusedWindowDidChange:newWindow];
}


@end
