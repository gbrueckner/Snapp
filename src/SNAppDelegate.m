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


#import "AXUIElement+Additions.h"
#import "NSScreen+Additions.h"
#import "SNAppDelegate.h"
@import QuartzCore;


#pragma mark - SNAppDelegate private interface


@interface SNAppDelegate ()

@property(readonly) NSMutableDictionary *storedWindowSizes;
@property(readonly) NSWindowController *windowController;
@property(readonly) SNWindowTracker *windowTracker;

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
        [window setBackgroundColor:[NSColor clearColor]];
        [window setIgnoresMouseEvents:YES];
        [window setLevel:NSFloatingWindowLevel];
        [window setOpaque:NO];
        [window setHidesOnDeactivate:NO];

        NSView *view = [[NSView alloc] initWithFrame:NSZeroRect];

        [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [window setContentView:view];
        [view release];

        _windowController = [[NSWindowController alloc] initWithWindow:window];

        [window release];

        CAShapeLayer *layer = [CAShapeLayer layer];
        [layer setFillColor:[[NSColor colorWithWhite:0.5 alpha:0.15] CGColor]];
        [layer setStrokeColor:[[NSColor blackColor] CGColor]];
        [layer setLineWidth:6.0];
        [layer setLineDashPattern:@[@15.0f, @5.0f]];

        CAShapeLayer *yellowLayer = [CAShapeLayer layer];
        [yellowLayer setFillColor:nil];
        [yellowLayer setStrokeColor:[[NSColor yellowColor] CGColor]];
        [yellowLayer setLineWidth:3.0];
        [yellowLayer setLineDashPattern:@[@12.0f, @8.0f]];

        [layer addSublayer:yellowLayer];

        [view setLayer:layer];
        [view setWantsLayer:YES];
    }

    return self;
}


- (void)dealloc {
    [_windowTracker release];
    [_storedWindowSizes release];
    [super dealloc];
}


- (NSRect)frameForHotZone:(SNHotZone)hotZone inScreen:(NSScreen *)screen {

    CGFloat x, y, w, h;

    switch(hotZone) {
        case kSNHotZoneDown:
            x = 0.0; y = 0.0; w = 1.0; h = 0.5;
            break;
        case kSNHotZoneLeft:
            x = 0.0; y = 0.0; w = 0.5; h = 1.0;
            break;
        case kSNHotZoneLowerLeft:
            x = 0.0; y = 0.0; w = 0.5; h = 0.5;
            break;
        case kSNHotZoneLowerRight:
            x = 0.5; y = 0.0; w = 0.5; h = 0.5;
            break;
        case kSNHotZoneRight:
            x = 0.5; y = 0.0; w = 0.5; h = 1.0;
            break;
        case kSNHotZoneUp:
            x = 0.0; y = 0.0; w = 1.0; h = 1.0;
            break;
        case kSNHotZoneUpperLeft:
            x = 0.0; y = 0.5; w = 0.5; h = 0.5;
            break;
        case kSNHotZoneUpperRight:
            x = 0.5; y = 0.5; w = 0.5; h = 0.5;
            break;
        case kSNHotZoneNone:
            return NSMakeRect(NAN, NAN, NAN, NAN);
    }

    NSRect visibleFrame = [screen visibleFrame];

    return NSMakeRect(visibleFrame.origin.x + x * visibleFrame.size.width,
                      visibleFrame.origin.y + y * visibleFrame.size.height,
                      w * visibleFrame.size.width,
                      h * visibleFrame.size.height);
}


- (void)window:(SNWindow *)window didMoveIntoHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen {

    if (hotZone == kSNHotZoneNone) {

        [self.windowController close];

        NSValue *sizeValue = [self.storedWindowSizes objectForKey:[NSNumber numberWithUnsignedInt:[window windowID]]];
        if (sizeValue != nil) {
            NSSize size = [sizeValue sizeValue];
            [self.storedWindowSizes removeObjectForKey:[NSNumber numberWithUnsignedInt:[window windowID]]];

            [window setFrame:NSMakeRect([NSEvent mouseLocation].x - size.width / 2,
                                        NSMaxY([screen frame]) - size.height,
                                        size.width,
                                        size.height)];
        }
    }
    else {

        NSRect frame = [self frameForHotZone:hotZone inScreen:screen];

        CGRect pathRect;
        pathRect.size = frame.size;
        pathRect.origin = CGPointZero;

        CGPathRef path = CGPathCreateWithRoundedRect(CGRectInset(pathRect, 4.0, 4.0),
                15.0,
                15.0,
                NULL);

        CAShapeLayer *layer = (CAShapeLayer *) [[[self.windowController window] contentView] layer];
        CAShapeLayer *yellowLayer = (CAShapeLayer *) [[layer sublayers] objectAtIndex:0];

        [layer setPath:path];
        [yellowLayer setPath:path];

        CGPathRelease(path);

        [[self.windowController window] setFrame:frame
                                    display:YES];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        [animation setFromValue:[NSNumber numberWithDouble:0.0]];
        [animation setToValue:[NSNumber numberWithDouble:20.0]];
        [animation setRepeatCount:HUGE_VALF];
        [animation setDuration:0.4];

        [layer removeAllAnimations];
        [layer addAnimation:animation forKey:nil];

        animation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        [animation setFromValue:[NSNumber numberWithDouble:18.5]];
        [animation setToValue:[NSNumber numberWithDouble:38.5]];
        [animation setRepeatCount:HUGE_VALF];
        [animation setDuration:0.4];

        [yellowLayer removeAllAnimations];
        [yellowLayer addAnimation:animation forKey:nil];

        [[self.windowController window] makeKeyAndOrderFront:nil];
    }
}


- (void)window:(SNWindow *)window wasDroppedInHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen {

    // If the window is dropped in the middle of the screen, nothing needs to be done.
    if (hotZone == kSNHotZoneNone)
        return;

    // If the window has been dragged into fullscreen mode, store the previous
    // size, so that this size can be restored later when dragging the window
    // down.
    if (hotZone == kSNHotZoneUp)
        [self.storedWindowSizes setObject:[NSValue valueWithSize:[window frame].size]
                                   forKey:[NSNumber numberWithUnsignedInt:[window windowID]]];

    // Snap the window to the appropriate frame.
    [window setFrame:[self frameForHotZone:hotZone inScreen:screen]];

    // Hide the border indicator.
    [self.windowController close];
}


- (void)window:(SNWindow *)window isBeingResizedOnScreen:(NSScreen *)screen {
    [self.storedWindowSizes removeObjectForKey:[NSNumber numberWithUnsignedInt:[window windowID]]];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    NSAlert *alert = [[NSAlert alloc] init];

    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:@"Enable Accessibility Features"];
    [alert setInformativeText:@"Snapp requires accessibility features. Please go to System Preferences > Security & Privacy > Accessibility to enable these features, then click OK."];

    // Using AXIsProcessTrustedWithOptions really has no benefit.
    while (!AXIsProcessTrusted())
        [alert runModal];

    [alert release];

    [self.windowTracker setDelegate:self];

    [[[NSWorkspace sharedWorkspace] notificationCenter] postNotificationName:NSWorkspaceDidActivateApplicationNotification
                                                                      object:self
                                                                    userInfo:@{NSWorkspaceApplicationKey: [[NSWorkspace sharedWorkspace] frontmostApplication]}];

    // Unhide the app. Otherwise, the indicator window might not be shown.
    [NSApp unhide];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.windowTracker setDelegate:nil];
}


@end
