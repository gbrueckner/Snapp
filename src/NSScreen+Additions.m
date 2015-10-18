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


#import "NSScreen+Additions.h"


@implementation NSScreen (NSScreenAdditions)


+ (NSScreen *)screenAtLocation:(CGPoint)location {

    for (NSScreen *screen in [NSScreen screens]) {
        if (NSMouseInRect(location, [screen frame], NO))
            return screen;
    }

    return nil;
}


+ (NSScreen *)screenAtZeroLocation {
    // NSZeroPoint doesn't work here because NSMouseInRect doesn't count the
    // lower screen border as belonging to the screen.
    return [NSScreen screenAtLocation:NSMakePoint(0.0, DBL_MIN)];
}


- (NSNumber *)screenNumber {
    return [[self deviceDescription] objectForKey:@"NSScreenNumber"];
}


+ (NSPoint)flipPoint:(NSPoint)point {
    NSRect frame = [[NSScreen screenAtZeroLocation] frame];
    return NSMakePoint(point.x, frame.size.height - point.y);
}


+ (NSRect)flipRect:(NSRect)rect {
    return NSMakeRect(rect.origin.x,
                      [NSScreen flipPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))].y,
                      rect.size.width,
                      rect.size.height);
}


@end
