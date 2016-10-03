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


#import "AXUIElement+Additions.h"


#ifdef DEBUG

extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);


AXError AXUIElementGetWindow(AXUIElementRef window, CGWindowID *windowID) {
    return _AXUIElementGetWindow(window, windowID);
}

#endif


#pragma mark - Getters


AXError AXUIElementGetSize(AXUIElementRef element, CGSize *sizeValue) {

    AXValueRef size;

    AXError error = AXUIElementCopyAttributeValue(element,
                                                  kAXSizeAttribute,
                                                  (CFTypeRef *) &size);
    if (error != kAXErrorSuccess)
        return error;

    error = AXValueGetValue(size, kAXValueCGSizeType, sizeValue) ? kAXErrorSuccess : kAXErrorFailure;
    CFRelease(size);
    return error;
}


AXError AXUIElementGetOrigin(AXUIElementRef element, CGPoint *originValue) {

    AXValueRef origin;

    AXError error = AXUIElementCopyAttributeValue(element,
                                                  kAXPositionAttribute,
                                                  (CFTypeRef *) &origin);
    if (error != kAXErrorSuccess)
        return error;

    error = AXValueGetValue(origin, kAXValueCGPointType, originValue) ? kAXErrorSuccess : kAXErrorFailure;
    CFRelease(origin);
    return error;
}


AXError AXUIElementGetFrame(AXUIElementRef element, CGRect *frame) {
    AXError error = AXUIElementGetOrigin(element, &frame->origin);
    if (error != kAXErrorSuccess)
        return error;
    return AXUIElementGetSize(element, &frame->size);
}


AXError AXUIElementCopyWindowAtPosition(CGPoint position, AXUIElementRef *window) {

    *window = NULL;

    AXUIElementRef systemWideElement = AXUIElementCreateSystemWide();
    AXUIElementRef element = NULL;
    CFStringRef role = NULL;

    // First, retrieve the element at the given position.
    AXError error = AXUIElementCopyElementAtPosition(systemWideElement,
                                                     position.x,
                                                     position.y,
                                                     &element);

    if (error != kAXErrorSuccess)
        goto end;

    // If this element is a window, return it.
    error = AXUIElementCopyAttributeValue(element,
                                          kAXRoleAttribute,
                                          (CFTypeRef *) &role);
    if (error != kAXErrorSuccess)
        goto end;

    if (CFStringCompare(role, kAXWindowRole, 0) == kCFCompareEqualTo) {
        *window = element;
        CFRetain(*window);
        goto end;
    }

    // Otherwise, return the window attribute.
    error = AXUIElementCopyAttributeValue(element,
                                          kAXWindowAttribute,
                                          (CFTypeRef *)window);

end:
    CFRelease(systemWideElement);
    if (element != NULL)
        CFRelease(element);
    if (role != NULL)
        CFRelease(role);
    return error;
}


AXError AXUIElementGetTitle(AXUIElementRef element, CFStringRef *title) {
    return AXUIElementCopyAttributeValue(element,
                                         kAXTitleAttribute,
                                         (CFTypeRef *) title);
}


#pragma mark - Setters


AXError AXUIElementSetSize(AXUIElementRef element, CGSize sizeValue) {

    AXValueRef size = AXValueCreate(kAXValueCGSizeType, &sizeValue);
    if (size == NULL)
        return kAXErrorFailure;

    AXError error = AXUIElementSetAttributeValue(element, kAXSizeAttribute, size);

    CFRelease(size);

    return error;
}


AXError AXUIElementSetOrigin(AXUIElementRef element, CGPoint originValue) {

    AXValueRef origin = AXValueCreate(kAXValueCGPointType, &originValue);
    if (origin == NULL)
        return kAXErrorFailure;

    AXError error = AXUIElementSetAttributeValue(element, kAXPositionAttribute, origin);

    CFRelease(origin);

    return error;
}


AXError AXUIElementSetFrame(AXUIElementRef element, CGRect frame) {
    AXError error = AXUIElementSetOrigin(element, frame.origin);
    if (error != kAXErrorSuccess)
        return error;
    return AXUIElementSetSize(element, frame.size);
}
