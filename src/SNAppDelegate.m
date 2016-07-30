/* Copyright 2015-2016 gbrueckner.
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
#import "SNViewController.h"
#import "SNPageViewController.h"
#import <GBVersionTracking/GBVersionTracking.h>
@import QuartzCore;


#pragma mark - SNAppDelegate private interface


@interface SNAppDelegate ()

@property(readonly) NSMutableDictionary *storedWindowSizes;
@property(readonly) NSWindowController *windowController;
@property(readonly) SNWindowTracker *windowTracker;
@property(readonly) NSWindowController *prefsWindowController;

@property NSUInteger visibility;

@end


#define kPrefsWindowVisibilityUser          0x1
#define kPrefsWindowVisibilityAccessibility 0x2
#define kPrefsWindowVisibilityUpdate        0x4


#pragma mark - SNAppDelegate implementation


@implementation SNAppDelegate


+ (NSURL *)repositoryURL {
    return [NSURL URLWithString:@"https://github.com/gbrueckner/Snapp/"];
}


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
        layer.strokeColor = [NSColor colorWithWhite:0 alpha:1].CGColor;

        // Don't use dot syntax here, see #4.
        [window.contentView setLayer:layer];
        [window.contentView setWantsLayer:YES];

        // Create the preferences window controller.
        NSWindow *prefsWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect
                                                            styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSFullSizeContentViewWindowMask)
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO];
        prefsWindow.title = @"Snapp";
        prefsWindow.titlebarAppearsTransparent = YES;
        [prefsWindow standardWindowButton:NSWindowMiniaturizeButton].hidden = YES;
        [prefsWindow standardWindowButton:NSWindowZoomButton].hidden = YES;
        [prefsWindow standardWindowButton:NSWindowCloseButton].target = self;
        [prefsWindow standardWindowButton:NSWindowCloseButton].action = @selector(hidePrefsWindow:);
        [prefsWindow setAnchorAttribute:NSLayoutAttributeCenterX
                     forOrientation:NSLayoutConstraintOrientationHorizontal];

        _prefsWindowController = [[NSWindowController alloc] initWithWindow:prefsWindow];

        NSViewController *prefsViewController = [[SNViewController alloc] initWithNibName:nil
                                                                                   bundle:nil];

        _prefsWindowController.contentViewController = prefsViewController;

        [prefsWindow release];
        [prefsViewController release];
    }

    return self;
}


- (void)dealloc {
    [_windowTracker release];
    [_windowController release];
    [_storedWindowSizes release];
    [_prefsWindowController release];
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

        CGPathRef path = CGPathCreateWithRect(CGRectInset(pathRect, 2, 2),
                                                     NULL);

        // Don't use dot syntax here, see #4.
        CAShapeLayer *layer = (CAShapeLayer *) [self.windowController.window.contentView layer];

        layer.path = path;

        CGPathRelease(path);

        [[self.windowController window] setFrame:frame
                                         display:YES];

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


- (void)checkForUpdates:(NSTimer *)timer {

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"checkForUpdates"])
        return;

    // Retrieve the up-to-date Info.plist dictionary from the repository.
    NSURL *remoteInfoDictionaryURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/gbrueckner/Snapp/master/Snapp.app/Contents/Info.plist"];
    NSDictionary *remoteInfoDictionary = [NSDictionary dictionaryWithContentsOfURL:remoteInfoDictionaryURL];
    NSString *newestVersion = [remoteInfoDictionary objectForKey:@"CFBundleVersion"];

    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    if ([newestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
        self.visibility |= kPrefsWindowVisibilityUpdate;
        [self.prefsWindowController.contentViewController transitionToUpdateViewController:self];
        [self showPrefsWindow:self];
    }
}


+ (void)openAccessibilityPreferences {
    NSURL *scriptURL = [[NSBundle mainBundle] URLForResource:@"OpenAccessibilityPreferences"
                                               withExtension:@"scpt"];
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL
                                                                   error:NULL];
    [script executeAndReturnError:NULL];
    [script release];
}


- (void)showPrefsWindow:(id) sender {
    if (!self.prefsWindowController.window.visible)
        [self.prefsWindowController.window center];
    [self.prefsWindowController.window makeKeyAndOrderFront:self];
}


- (void)hidePrefsWindow:(id)sender {
    self.visibility = 0;
    [self.prefsWindowController.window orderOut:self];
}


- (void)checkForAccessibilityAPI {

    // If Snapp isn't a trusted process and the alert isn't shown already, show
    // it.
    if (!AXIsProcessTrusted() && (self.visibility & kPrefsWindowVisibilityAccessibility) == 0) {

        self.visibility |= kPrefsWindowVisibilityAccessibility;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.prefsWindowController.contentViewController transitionToAccessibilityViewController:self];
            [self showPrefsWindow:self];
        });

        [SNAppDelegate openAccessibilityPreferences];
    }
    // If Snapp is a trusted process and the alert is shown, hide it.
    else if (AXIsProcessTrusted() && (self.visibility & kPrefsWindowVisibilityAccessibility) != 0) {

        self.visibility &= ~kPrefsWindowVisibilityAccessibility;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.visibility == 0)
                [self hidePrefsWindow:self];
            [self.prefsWindowController.contentViewController transitionToPreferencesViewController:self];
        });
    }

    // Continuously recheck the trust status. If the process is trusted, it is
    // safe to recheck every 10 seconds. If the process is not trusted, recheck
    // every 0.1 seconds to quickly detect when the alert can be hidden.
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                          (AXIsProcessTrusted() ? 10 : 0.1) * NSEC_PER_SEC);
    dispatch_after(delay, dispatch_get_current_queue(), ^{
        [self checkForAccessibilityAPI];
    });
}


- (void)setup {

    // Set default user defaults.
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{    @"openAtLogin": @NO,
                                                                @"playSnapSound": @YES,
                                                              @"checkForUpdates": @YES}];


    // Start checking for the Accessibility APIs on a background queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkForAccessibilityAPI];
    });

    self.windowTracker.delegate = self;

    [[NSWorkspace sharedWorkspace].notificationCenter postNotificationName:NSWorkspaceDidActivateApplicationNotification
                                                                    object:self
                                                                  userInfo:@{NSWorkspaceApplicationKey: [NSWorkspace sharedWorkspace].frontmostApplication}];

    // Unhide the app. Otherwise, the indicator window might not be shown.
    [NSApp unhide];

    // Check for updates once a day.
    NSTimer *checkForUpdatesTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                             interval:86400
                                                               target:self
                                                             selector:@selector(checkForUpdates:)
                                                             userInfo:nil
                                                              repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:checkForUpdatesTimer
                                 forMode:NSDefaultRunLoopMode];

    [checkForUpdatesTimer release];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [GBVersionTracking track];

    if ([GBVersionTracking isFirstLaunchEver]) {
        self.visibility |= kPrefsWindowVisibilityUser;
        [self showPrefsWindow:self];
    }
    else
        [self setup];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {

    if (!flag)
        [self.prefsWindowController.contentViewController transitionToPreferencesViewController:self];

    self.visibility |= kPrefsWindowVisibilityUser;
    [self showPrefsWindow:self];

    return NO;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.windowTracker.delegate = nil;
}


@end
