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
#import "SNFocusedWindowTracker.h"
#import "SNWindow.h"


@protocol SNWindowTrackerDelegate

- (void)window:(SNWindow *)window didMoveIntoHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen;
- (void)window:(SNWindow *)window wasDroppedInHotZone:(SNHotZone)hotZone ofScreen:(NSScreen *)screen;
- (void)window:(SNWindow *)window isBeingResizedOnScreen:(NSScreen *)screen;

@end


@interface SNWindowTracker : NSObject <SNFocusedWindowTrackerDelegate>

@property(retain) id<SNWindowTrackerDelegate> delegate;

@end
