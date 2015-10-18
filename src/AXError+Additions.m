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


#import "AXError+Additions.h"


NSString *AXErrorToNSString(AXError error) {
    switch (error) {
        case kAXErrorSuccess:
            return @"AXErrorSuccess";
        case kAXErrorFailure:
            return @"AXErrorFailure";
        case kAXErrorIllegalArgument:
            return @"AXErrorIllegalArgument";
        case kAXErrorInvalidUIElement:
            return @"AXErrorInvalidUIElement";
        case kAXErrorInvalidUIElementObserver:
            return @"AXErrorInvalidUIElementObserver";
        case kAXErrorCannotComplete:
            return @"AXErrorCannotComplete";
        case kAXErrorAttributeUnsupported:
            return @"AXErrorAttributeUnsupported";
        case kAXErrorActionUnsupported:
            return @"AXErrorActionUnsupported";
        case kAXErrorNotificationUnsupported:
            return @"AXErrorNotificationUnsupported";
        case kAXErrorNotImplemented:
            return @"AXErrorNotImplemented";
        case kAXErrorNotificationAlreadyRegistered:
            return @"AXErrorNotificationAlreadyRegistered";
        case kAXErrorNotificationNotRegistered:
            return @"AXErrorNotificationNotRegistered";
        case kAXErrorAPIDisabled:
            return @"AXErrorAPIDisabled";
        case kAXErrorNoValue:
            return @"AXErrorNoValue";
        case kAXErrorParameterizedAttributeUnsupported:
            return @"AXErrorParameterizedAttributeUnsupported";
        case kAXErrorNotEnoughPrecision:
            return @"AXErrorNotEnoughPrecision";
        default:
            return nil;
    }
}
