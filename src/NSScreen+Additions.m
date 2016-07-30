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


#import "NSScreen+Additions.h"


CGFloat NSPointDistanceFromPoint(NSPoint aPoint, NSPoint bPoint) {
    return hypot(aPoint.x - bPoint.x, aPoint.y - bPoint.y);
}


CGFloat NSPointDistanceFromRect(NSPoint aPoint, NSRect aRect) {

    NSPoint lowerLeftCorner  = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
    NSPoint lowerRightCorner = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
    NSPoint upperLeftCorner  = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
    NSPoint upperRightCorner = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));

    if      (aPoint.x < lowerLeftCorner.x  && aPoint.y < lowerLeftCorner.y)
        return NSPointDistanceFromPoint(aPoint, lowerLeftCorner);
    else if (aPoint.x > lowerRightCorner.x && aPoint.y < lowerRightCorner.y)
        return NSPointDistanceFromPoint(aPoint, lowerRightCorner);
    else if (aPoint.x < upperLeftCorner.x  && aPoint.y > upperLeftCorner.y)
        return NSPointDistanceFromPoint(aPoint, upperLeftCorner);
    else if (aPoint.x > upperRightCorner.x && aPoint.y > upperRightCorner.y)
        return NSPointDistanceFromPoint(aPoint, upperRightCorner);

    else if (aPoint.x < NSMinX(aRect))
        return NSMinX(aRect) - aPoint.x;
    else if (aPoint.x > NSMaxX(aRect))
        return aPoint.x - NSMaxX(aRect);
    else if (aPoint.y < NSMinY(aRect))
        return NSMinY(aRect) - aPoint.y;
    else if (aPoint.y > NSMaxY(aRect))
        return aPoint.y - NSMaxY(aRect);

    return 0;
}


@implementation NSScreen (NSScreenAdditions)


+ (NSArray *)screensWithinDistance:(CGFloat)distance ofLocation:(NSPoint)aPoint {

    NSMutableArray *screens = [NSMutableArray array];

    for (NSScreen *screen in [NSScreen screens]) {
        if (NSPointDistanceFromRect(aPoint, screen.frame) <= distance)
            [screens addObject:screen];
    }

    return screens;
}


+ (NSScreen *)screenAtLocation:(NSPoint)location {

    NSScreen *closestScreen = [NSScreen mainScreen];
    CGFloat minimumDistance = CGFLOAT_MAX;

    for (NSScreen *screen in [NSScreen screens]) {

        CGFloat distance = NSPointDistanceFromRect(location, screen.frame);

        if (distance == 0)
            return screen;
        else if (distance < minimumDistance) {
            closestScreen = screen;
            minimumDistance = distance;
        }
    }

    return closestScreen;
}


+ (NSScreen *)screenAtZeroLocation {
    // NSZeroPoint doesn't work here because NSMouseInRect doesn't count the
    // lower screen border as belonging to the screen.
    return [NSScreen screenAtLocation:NSZeroPoint];
}


- (NSNumber *)screenNumber {
    return [self.deviceDescription objectForKey:@"NSScreenNumber"];
}


+ (NSPoint)flipPoint:(NSPoint)point {
    NSRect frame = [NSScreen screenAtZeroLocation].frame;
    return NSMakePoint(point.x, NSHeight(frame) - point.y);
}


+ (NSRect)flipRect:(NSRect)rect {
    return NSMakeRect(NSMinX(rect),
                      [NSScreen flipPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))].y,
                      NSWidth(rect),
                      NSHeight(rect));
}


@end
