/* Copyright 2015-2018 gbrueckner.
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


#include "CGWindow+Additions.h"
#import "AXUIElement+Additions.h"


#ifndef APP_STORE
extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID*);
#endif


CGWindowID CGWindowWithInfo(AXUIElementRef window, CGPoint location) {

    AXError error;
    CGWindowID windowID = kCGNullWindowID;

#ifndef APP_STORE
    error = _AXUIElementGetWindow(window, &windowID);
#else
    pid_t pid;
    error = AXUIElementGetPid(window, &pid);
    if (error != kAXErrorSuccess)
        return kCGNullWindowID;

    CFStringRef title = NULL;
    error = AXUIElementGetTitle(window, &title);

    CGRect frame;
    error = AXUIElementGetFrame(window, &frame);
    if (error != kAXErrorSuccess)
        return kCGNullWindowID;

    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements,
                                                       kCGNullWindowID);
    if (windowList == NULL)
        return kCGNullWindowID;

    for (CFIndex i = 0; i < CFArrayGetCount(windowList); i++) {

        CFDictionaryRef window = CFArrayGetValueAtIndex(windowList, i);

        int windowPID;
        CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowOwnerPID),
                         kCFNumberIntType,
                         &windowPID);

        if (windowPID != pid)
            continue;

        CGRect windowBounds;
        CGRectMakeWithDictionaryRepresentation(CFDictionaryGetValue(window, kCGWindowBounds),
                                               &windowBounds);

        if (!CGSizeEqualToSize(frame.size, windowBounds.size))
            continue;

        if (!CGRectContainsPoint(windowBounds, location))
            continue;

        CFStringRef windowName = CFDictionaryGetValue(window, kCGWindowName);
        if (windowName == NULL || title == NULL || CFStringCompare(windowName, title, 0) == kCFCompareEqualTo) {
            CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber),
                             kCGWindowIDCFNumberType,
                             &windowID);
            break;
        }
    }

    CFRelease(windowList);
#endif

    return windowID;
}


CGWindowID CGWindowAtPosition(CGPoint position) {

    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements,
                                                       kCGNullWindowID);
    if (windowList == NULL)
        return kCGNullWindowID;

    CGWindowID windowID = kCGNullWindowID;

    for (CFIndex i = 0; i < CFArrayGetCount(windowList); i++) {

        CFDictionaryRef window = CFArrayGetValueAtIndex(windowList, i);

        int layer;
        CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowLayer),
                         kCFNumberIntType,
                         &layer);
        if (layer != 0)
            continue;

        CGRect windowBounds;
        CGRectMakeWithDictionaryRepresentation(CFDictionaryGetValue(window, kCGWindowBounds),
                                               &windowBounds);

        if (CGRectContainsPoint(windowBounds, position)) {
            CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber),
                             kCGWindowIDCFNumberType,
                             &windowID);
            break;
        }
    }

    CFRelease(windowList);

    return windowID;
}


CGRect CGWindowGetBounds(CGWindowID windowID) {

    CGRect bounds;

    CFArrayRef array = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow,
                                                  windowID);

    if (CFArrayGetCount(array) != 1)
        return CGRectMake(NAN, NAN, NAN, NAN);

    CFDictionaryRef dict = CFArrayGetValueAtIndex(array, 0);
    CFDictionaryRef _bounds = CFDictionaryGetValue(dict, kCGWindowBounds);
    CGRectMakeWithDictionaryRepresentation(_bounds, &bounds);

    CFRelease(array);

    return bounds;
}
