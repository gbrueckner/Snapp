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


#import "SNAppDelegate.h"
#import "AXUIElement+Additions.h"
#import "NSAttributedString+Hyperlink.h"
#import "NSScreen+Additions.h"
#import "SNPreferencesViewController.h"
@import QuartzCore;


#pragma mark - SNAppDelegate private interface


@interface SNAppDelegate ()

@property(readonly) NSMutableDictionary *storedWindowSizes;
@property(readonly) NSWindowController *windowController;
@property(readonly) SNWindowTracker *windowTracker;
@property(readonly) NSWindowController *prefsWindowController;

@end


#pragma mark - SNAppDelegate implementation


@implementation SNAppDelegate


- (instancetype)init {

    if ((self = [super init])) {

        _storedWindowSizes = [[NSMutableDictionary alloc] init];
        _windowTracker = [[SNWindowTracker alloc] init];

        NSWindow *window = [[NSWindow alloc] initWithContentRect:NSZeroRect
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:YES];
        window.backgroundColor = [NSColor clearColor];
        window.ignoresMouseEvents = YES;
        window.level = NSFloatingWindowLevel;
        window.opaque = NO;
        window.hidesOnDeactivate = NO;

        _windowController = [[NSWindowController alloc] initWithWindow:window];

        [window release];

        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [NSColor colorWithWhite:0.5 alpha:0.15].CGColor;
        layer.lineDashPattern = @[@15, @5];
        layer.lineWidth = 6;
        layer.strokeColor = [NSColor blackColor].CGColor;

        CAShapeLayer *yellowLayer = [CAShapeLayer layer];
        yellowLayer.fillColor = nil;
        yellowLayer.lineDashPattern = @[@12, @8];
        yellowLayer.lineWidth = 3;
        yellowLayer.strokeColor = [NSColor yellowColor].CGColor;

        [layer addSublayer:yellowLayer];

        // Don't use dot syntax here, see #4.
        [window.contentView setLayer:layer];
        [window.contentView setWantsLayer:YES];

        // Create the preferences window controller.
        NSWindow *prefsWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect
                                                            styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO];
        prefsWindow.title = @"Snapp";

        _prefsWindowController = [[NSWindowController alloc] initWithWindow:prefsWindow];

        NSViewController *prefsViewController = [[SNPreferencesViewController alloc] initWithNibName:nil
                                                                                              bundle:nil];

        _prefsWindowController.contentViewController = prefsViewController;

        [_prefsWindowController.window setFrame:NSMakeRect(0, 0, 298, 326)
                                        display:YES];

        [prefsWindow release];
        [prefsViewController release];
    }

    return self;
}


- (void)dealloc {
    [_windowTracker release];
    [_prefsWindowController release];
    [_storedWindowSizes release];
    [_windowController release];
    [super dealloc];
}


- (NSRect)resizedFrameForHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen {

    CGFloat x, y, w, h;

    switch(hotZone) {
        case kSNHotZoneDown:
            x = 0;   y = 0;   w = 1;   h = 0.5;
            break;
        case kSNHotZoneLeft:
            x = 0;   y = 0;   w = 0.5; h = 1;
            break;
        case kSNHotZoneLowerLeft:
            x = 0;   y = 0;   w = 0.5; h = 0.5;
            break;
        case kSNHotZoneLowerRight:
            x = 0.5; y = 0;   w = 0.5; h = 0.5;
            break;
        case kSNHotZoneRight:
            x = 0.5; y = 0;   w = 0.5; h = 1;
            break;
        case kSNHotZoneUp:
            x = 0;   y = 0;   w = 1;   h = 1;
            break;
        case kSNHotZoneUpperLeft:
            x = 0;   y = 0.5; w = 0.5; h = 0.5;
            break;
        case kSNHotZoneUpperRight:
            x = 0.5; y = 0.5; w = 0.5; h = 0.5;
            break;
        case kSNHotZoneNone:
            return NSMakeRect(NAN, NAN, NAN, NAN);
    }

    NSRect visibleFrame = screen.visibleFrame;

    return NSMakeRect(NSMinX(visibleFrame) + x * NSWidth(visibleFrame),
                      NSMinY(visibleFrame) + y * NSHeight(visibleFrame),
                      w * NSWidth(visibleFrame),
                      h * NSHeight(visibleFrame));
}


- (NSRect)movedFrame:(NSRect) frame forHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen {

    NSRect visibleFrame = screen.visibleFrame;

    if (   hotZone == kSNHotZoneLowerLeft
        || hotZone == kSNHotZoneLeft
        || hotZone == kSNHotZoneUpperLeft) {
        frame.origin.x = NSMinX(visibleFrame);
    }
    if (   hotZone == kSNHotZoneLowerRight
        || hotZone == kSNHotZoneRight
        || hotZone == kSNHotZoneUpperRight) {
        frame.origin.x = NSMaxX(visibleFrame) - NSWidth(frame);
    }
    if (   hotZone == kSNHotZoneLowerLeft
        || hotZone == kSNHotZoneDown
        || hotZone == kSNHotZoneLowerRight) {
        frame.origin.y = NSMinY(visibleFrame);
    }
    if (   hotZone == kSNHotZoneUpperLeft
        || hotZone == kSNHotZoneUpperRight) {
        frame.origin.y = NSMaxY(visibleFrame) - NSHeight(frame);
    }
    if (   hotZone == kSNHotZoneLeft
        || hotZone == kSNHotZoneUp
        || hotZone == kSNHotZoneRight) {
        frame.origin.y = NSMinY(visibleFrame) + (NSHeight(visibleFrame) - NSHeight(frame)) / 2;
    }
    if (   hotZone == kSNHotZoneUp
        || hotZone == kSNHotZoneDown) {
        frame.origin.x = NSMinX(visibleFrame) + (NSWidth(visibleFrame) - NSWidth(frame)) / 2;
    }

    return frame;
}


- (NSRect)frameForWindow:(SNWindow *)window inHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *) screen {
    if (window.isResizable)
        return [self resizedFrameForHotZone:hotZone
                                   ofScreen:screen];
    else
        return [self movedFrame:window.frame
                     forHotZone:hotZone
                       ofScreen:screen];
}


- (void)window:(SNWindow *)window didMoveIntoHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen {

    if (hotZone == kSNHotZoneNone) {

        [self.windowController close];

        NSValue *sizeValue = [self.storedWindowSizes objectForKey:[NSNumber numberWithUnsignedInt:window.windowID]];
        if (sizeValue != nil) {
            NSSize size = sizeValue.sizeValue;
            [self.storedWindowSizes removeObjectForKey:[NSNumber numberWithUnsignedInt:window.windowID]];

            [window setFrame:NSMakeRect([NSEvent mouseLocation].x - size.width / 2,
                                        NSMaxY([screen frame]) - size.height,
                                        size.width,
                                        size.height)];
        }
    }
    else {

        NSRect frame = [self frameForWindow:window
                                  inHotZone:hotZone
                                   ofScreen:screen];

        CGRect pathRect;
        pathRect.size = frame.size;
        pathRect.origin = CGPointZero;

        CGPathRef path = CGPathCreateWithRoundedRect(CGRectInset(pathRect, 4, 4),
                                                     15,
                                                     15,
                                                     NULL);

        // Don't use dot syntax here, see #4.
        CAShapeLayer *layer = (CAShapeLayer *) [self.windowController.window.contentView layer];
        CAShapeLayer *yellowLayer = (CAShapeLayer *) [layer.sublayers objectAtIndex:0];

        layer.path = path;
        yellowLayer.path = path;

        CGPathRelease(path);

        [[self.windowController window] setFrame:frame
                                         display:YES];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        animation.fromValue = @0;
        animation.toValue = @20;
        animation.repeatCount = HUGE_VALF;
        animation.duration = 0.4;

        [layer addAnimation:animation forKey:nil];

        animation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        animation.fromValue = @18.5;
        animation.toValue = @38.5;
        animation.repeatCount = HUGE_VALF;
        animation.duration = 0.4;

        [yellowLayer addAnimation:animation forKey:nil];

        [self.windowController.window makeKeyAndOrderFront:nil];
    }
}


- (void)window:(SNWindow *)window wasDroppedInHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen {

    // If the window is dropped in the middle of the screen, nothing needs to be done.
    if (hotZone == kSNHotZoneNone)
        return;

    // If the window has been dragged into fullscreen mode, store the previous
    // size, so that this size can be restored later when dragging the window
    // down.
    if (hotZone == kSNHotZoneUp && [window isResizable])
        [self.storedWindowSizes setObject:[NSValue valueWithSize:window.frame.size]
                                   forKey:[NSNumber numberWithUnsignedInt:window.windowID]];

    // Snap the window to the appropriate frame.
    NSRect frame = [self frameForWindow:window
                              inHotZone:hotZone
                               ofScreen:screen];
    window.frame = frame;

    // Play a 'pop' sound if desired.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"playSnapSound"])
        [[NSSound soundNamed:@"Pop"] play];

    // Hide the border indicator.
    [self.windowController close];
}


- (void)window:(SNWindow *)window isBeingResizedOnScreen:(NSScreen *)screen {
    [self.storedWindowSizes removeObjectForKey:[NSNumber numberWithUnsignedInt:window.windowID]];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    // Set default user defaults.
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"openAtLogin": @NO, @"playSnapSound": @YES}];

    NSAlert *alert = [[NSAlert alloc] init];

    alert.alertStyle = NSInformationalAlertStyle;
    alert.messageText = @"Enable Accessibility Features";
    alert.informativeText = @"Snapp requires accessibility features. Please go to System Preferences > Security & Privacy > Accessibility to enable these features, then click OK.";

    // Using AXIsProcessTrustedWithOptions really has no benefit.
    while (!AXIsProcessTrusted())
        [alert runModal];

    [alert release];

    self.windowTracker.delegate = self;

    [[NSWorkspace sharedWorkspace].notificationCenter postNotificationName:NSWorkspaceDidActivateApplicationNotification
                                                                    object:self
                                                                  userInfo:@{NSWorkspaceApplicationKey: [NSWorkspace sharedWorkspace].frontmostApplication}];

    // Unhide the app. Otherwise, the indicator window might not be shown.
    [NSApp unhide];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {

    // Don't show the preferences window twice.
    if (flag)
        return NO;

    [self.prefsWindowController.window center];
    [self.prefsWindowController.window makeKeyAndOrderFront:self];

    return NO;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.windowTracker.delegate = nil;
}


@end
