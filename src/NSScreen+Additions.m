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


@implementation NSScreen (NSScreenAdditions)


+ (NSArray *)screensAtLocation:(CGPoint)location withFuzziness:(CGFloat)fuzziness {

    NSMutableArray *screens = [NSMutableArray array];

    for (NSScreen *screen in [NSScreen screens]) {
        NSRect frame = NSInsetRect(screen.frame, -fuzziness, -fuzziness);
        if (NSMouseInRect(location, frame, NO))
            [screens addObject:screen];
    }

    return screens;
}


+ (NSScreen *)screenAtLocation:(CGPoint)location {

    NSArray *screens = [NSScreen screensAtLocation:location
                                     withFuzziness:0];

    return (screens.count == 1) ? screens.firstObject : nil;
}


+ (NSScreen *)screenAtZeroLocation {
    // NSZeroPoint doesn't work here because NSMouseInRect doesn't count the
    // lower screen border as belonging to the screen.
    return [NSScreen screenAtLocation:NSMakePoint(0, DBL_MIN)];
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
