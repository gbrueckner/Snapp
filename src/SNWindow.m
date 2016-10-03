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


#import "SNWindow.h"
#import "AXUIElement+Additions.h"
#import "CGWindow+Additions.h"
#import "NSScreen+Additions.h"
#import "SNLog.h"


@interface SNWindow ()

@property(readonly) AXUIElementRef windowElement;

@end


@implementation SNWindow


- (instancetype)initWithID:(CGWindowID)windowID element:(AXUIElementRef)windowElement {

    if ((self = [super init])) {
        _windowID = windowID;
        _windowElement = windowElement;
        CFRetain(_windowElement);

#ifdef DEBUG

        // Check whether the window is consistent using private APIs.
        CGWindowID correctWindowID;
        AXUIElementGetWindow(_windowElement, &correctWindowID);

        if (_windowID != correctWindowID)
            SNLog(@"Created inconsistent window.");
#endif
    }

    return self;
}


+ (instancetype)windowWithID:(CGWindowID)windowID element:(AXUIElementRef)element {
    return [[[self alloc] initWithID:windowID element:element] autorelease];
}


+ (instancetype)windowAtLocation:(NSPoint)location {

    CGPoint flippedLocation = NSPointToCGPoint([NSScreen flipPoint:location]);

    AXUIElementRef windowElement;
    if (AXUIElementCopyWindowAtPosition(flippedLocation, &windowElement) != kAXErrorSuccess) {
        SNLog(@"AXUIElementCopyWindowAtPosition() failed.");
        return nil;
    }

    CGWindowID windowID = CGWindowWithInfo(windowElement, flippedLocation);

    if (windowID == kCGNullWindowID) {
        SNLog(@"CGWindowWithInfo() failed.");
        CFRelease(windowElement);
        return nil;
    }

    return [[[self alloc] initWithID:windowID element:windowElement] autorelease];
}


- (void)dealloc {
    CFRelease(_windowElement);
    [super dealloc];
}


- (void)setFrame:(NSRect)frame {
    AXUIElementSetFrame(self.windowElement,
                        NSRectToCGRect([NSScreen flipRect:frame]));
}


- (NSRect)frame {
    NSRect flippedFrame = NSRectFromCGRect(CGWindowGetBounds(self.windowID));
    return [NSScreen flipRect:flippedFrame];
}


- (BOOL)resizable {

    Boolean resizable;
    AXError error = AXUIElementIsAttributeSettable(self.windowElement, kAXSizeAttribute, &resizable);

    if (error == kAXErrorSuccess && resizable)
        return YES;
    else
        return NO;
}


- (NSString *)description {

    CFStringRef description;

    if (AXUIElementGetTitle(self.windowElement, &description) != kAXErrorSuccess)
        return nil;

    return (NSString *) description;
}


@end
