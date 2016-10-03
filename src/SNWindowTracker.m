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


#import "SNWindowTracker.h"
#import "AXUIElement+Additions.h"
#import "AXError+Additions.h"
#import "NSScreen+Additions.h"
#import "CGWindow+Additions.h"


#pragma mark - SNWindowTracker private interface


@interface SNWindowTracker ()

@property(readonly) CFRunLoopSourceRef mouseRunLoopSource;
@property(readonly) SNFocusedWindowTracker *focusedWindowTracker;
@property NSRect initialFrame;
@property SNHotZone lastHotZone;
@property(retain) SNWindow *focusedWindow;
@property enum {
              kSNWindowTrackerStateIdle,
              kSNWindowTrackerStateWaitingForDrag,
              kSNWindowTrackerStateWindowIsMoving,
              kSNWindowTrackerStateWindowIsResizing,
          } state;

- (void)windowDidMoveToPoint:(NSPoint)point;
- (void)windowWasDroppedAtPoint:(NSPoint)point;

- (void)leftMouseDownAtPoint:(NSPoint)point;
- (void)leftMouseDraggedToPoint:(NSPoint)point;
- (void)leftMouseUpAtPoint:(NSPoint)point;

@end


#pragma mark - CGEventTapCallBack callback for mouse events


CGEventRef mouseEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {

    // The event location is given in a coordinate system which has the origin
    // in the upper left corner of the screen. Most other functionality, in
    // particular NSScreen, expects coordinates in a system which has the
    // origin at the lower left corner of the screen. So, the coordinate has to
    // be flipped first.
    CGPoint eventPoint = CGEventGetLocation(event);
    NSPoint flippedPoint = [NSScreen flipPoint:eventPoint];

    switch (type) {
        case kCGEventLeftMouseDown:
            [(SNWindowTracker *)refcon leftMouseDownAtPoint:flippedPoint];
            break;
        case kCGEventLeftMouseDragged:
            [(SNWindowTracker *)refcon leftMouseDraggedToPoint:flippedPoint];
            break;
        case kCGEventLeftMouseUp:
            [(SNWindowTracker *)refcon leftMouseUpAtPoint:flippedPoint];
            break;
        default:
            break;
    }

    return event;
}


#pragma mark - SNWindowTracker implementation


@implementation SNWindowTracker


- (instancetype)init {
    if ((self = [super init])) {

        _focusedWindowTracker = [[SNFocusedWindowTracker alloc] initWithDelegate:self];

        CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap,
                                                  kCGHeadInsertEventTap,
                                                  kCGEventTapOptionListenOnly,
                                                  CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventLeftMouseDragged) | CGEventMaskBit(kCGEventLeftMouseUp),
                                                  mouseEventCallback,
                                                  self);
        if (eventTap != NULL) {
            _mouseRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
            CFRelease(eventTap);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), _mouseRunLoopSource, kCFRunLoopCommonModes);
        }
    }

    return self;
}


- (void)dealloc {
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _mouseRunLoopSource, kCFRunLoopCommonModes);
    self.focusedWindow = nil;
    [super dealloc];
}


- (SNHotZone)hotZoneAtLocation:(NSPoint)point {

    NSScreen *screen = [NSScreen screenAtLocation:point];
    NSRect screenFrame = screen.frame;

    NSRect visibleScreenFrame = screen.visibleFrame;
    CGFloat menubarHeight = NSMaxY(screenFrame) - NSMaxY(visibleScreenFrame);

    // These margins describe the hot zones of the screen.
    CGFloat marginTop = menubarHeight;
    CGFloat marginRight = 1;
    CGFloat marginBottom = 1;
    CGFloat marginLeft = 1;

    // Use smart snapping, i.e. if this point is in the vicinity of multiple
    // screens, make the hot zones larger.
    if ([NSScreen screensWithinDistance:menubarHeight ofLocation:point].count > 1) {
        marginRight = menubarHeight;
        marginBottom = menubarHeight;
        marginLeft = menubarHeight;
    }

    if (point.x <= NSMinX(screenFrame) + marginLeft) {
        if (point.y <= NSMinY(screenFrame) + marginBottom)
            return kSNHotZoneLowerLeft;
        else if (point.y >= NSMaxY(screenFrame) - marginTop)
            return kSNHotZoneUpperLeft;
        else
            return kSNHotZoneLeft;
    }
    else if (point.x >= NSMaxX(screenFrame) - marginRight) {
        if (point.y <= NSMinY(screenFrame) + marginBottom)
            return kSNHotZoneLowerRight;
        else if (point.y >= NSMaxY(screenFrame) - marginTop)
            return kSNHotZoneUpperRight;
        else
            return kSNHotZoneRight;
    }
    else if (point.y <= NSMinY(screenFrame) + marginBottom)
        return kSNHotZoneDown;
    else if (point.y >= NSMaxY(screenFrame) - marginTop)
        return kSNHotZoneUp;

    return kSNHotZoneNone;
}


- (void)windowDidMoveToPoint:(NSPoint)point {
    SNHotZone currentHotZone = [self hotZoneAtLocation:point];
    if (currentHotZone != self.lastHotZone) {
        [self.delegate window:self.focusedWindow
           didMoveIntoHotZone:currentHotZone
                     ofScreen:[NSScreen screenAtLocation:point]];
        self.lastHotZone = currentHotZone;
    }
}


- (void)windowWasDroppedAtPoint:(NSPoint)point {
    [self.delegate window:self.focusedWindow
      wasDroppedInHotZone:[self hotZoneAtLocation:point]
                 ofScreen:[NSScreen screenAtLocation:point]];
}


#pragma mark - Mouse event callbacks


- (void)leftMouseDownAtPoint:(NSPoint)point{
    [self focusedWindowDidChange:[SNWindow windowAtLocation:point]];
    self.state = kSNWindowTrackerStateWaitingForDrag;
}


- (void)leftMouseDraggedToPoint:(NSPoint)point {
    if (self.state == kSNWindowTrackerStateWaitingForDrag) {
        // Here, you can't use AXUIElementGetFrame because the results are not
        // update quickly enough (when dragging, the result is only updated
        // once the user doesn't move the mouse for a moment). So, use
        // CGWindowGetBounds instead.
        NSRect currentFrame = self.focusedWindow.frame;
        if (!NSEqualSizes(self.initialFrame.size, currentFrame.size)) {
            [self.delegate window:self.focusedWindow isBeingResizedOnScreen:[NSScreen screenAtLocation:point]];
            self.state = kSNWindowTrackerStateWindowIsResizing;
        }
        else if (!NSEqualPoints(self.initialFrame.origin, currentFrame.origin))
            self.state = kSNWindowTrackerStateWindowIsMoving;
    }
    if (self.state == kSNWindowTrackerStateWindowIsMoving)
        [self windowDidMoveToPoint:point];
}


- (void)leftMouseUpAtPoint:(NSPoint)point {
    if (self.state == kSNWindowTrackerStateWindowIsMoving)
        [self windowWasDroppedAtPoint:point];
    self.state = kSNWindowTrackerStateIdle;
}


#pragma mark - SNFocusedWindowTrackerDelegate implementation


- (void)focusedWindowDidChange:(SNWindow *)window {

    if (!window)
        return;

    self.focusedWindow = window;
    self.initialFrame = self.focusedWindow.frame;

    if (self.state != kSNWindowTrackerStateIdle)
        self.state = kSNWindowTrackerStateWaitingForDrag;
}


@end
