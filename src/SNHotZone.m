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


@import AppKit;
#import "SNHotZone.h"


NSString *SNHotZoneToNSString(SNHotZone hotZone) {
    switch (hotZone) {
        case kSNHotZoneUp:
            return @"SNHotZoneUp";
        case kSNHotZoneUpperRight:
            return @"SNHotZoneUpperRight";
        case kSNHotZoneRight:
            return @"SNHotZoneRight";
        case kSNHotZoneLowerRight:
            return @"SNHotZoneLowerRight";
        case kSNHotZoneDown:
            return @"SNHotZoneDown";
        case kSNHotZoneLowerLeft:
            return @"SNHotZoneLowerLeft";
        case kSNHotZoneLeft:
            return @"SNHotZoneLeft";
        case kSNHotZoneUpperLeft:
            return @"SNHotZoneUpperLeft";
        case kSNHotZoneNone:
            return @"SNHotZoneNone";
    }
}
