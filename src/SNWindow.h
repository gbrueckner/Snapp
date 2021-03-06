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


@import AppKit;


@interface SNWindow : NSObject

@property(readonly) CGWindowID windowID;
@property           NSRect     frame;
@property(readonly) BOOL       resizable;

+ (instancetype)windowAtLocation:(NSPoint)location;
+ (instancetype)windowWithID:(CGWindowID)windowID element:(AXUIElementRef)element;

@end
