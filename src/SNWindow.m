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


#import "SNWindow.h"
#import "AXUIElement+Additions.h"
#import "CGWindow+Additions.h"
#import "NSScreen+Additions.h"


@interface SNWindow ()

@property(readonly) AXUIElementRef windowElement;

@end


@implementation SNWindow


- (instancetype)initWithWindowElement:(AXUIElementRef)window {

    if ((self = [super init])) {

        if (AXUIElementGetWindow(window, &_windowID) != kAXErrorSuccess)
            return nil;

        _windowElement = window;
        CFRetain(_windowElement);
    }

    return self;
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


- (BOOL)isResizable {

    Boolean resizable;
    AXError error = AXUIElementIsAttributeSettable(self.windowElement, kAXSizeAttribute, &resizable);

    if (error == kAXErrorSuccess && resizable)
        return YES;
    else
        return NO;
}


@end
