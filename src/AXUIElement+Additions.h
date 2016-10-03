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

#ifdef DEBUG

// This function uses a private API, so only use it in debug builds.
AXError AXUIElementGetWindow(AXUIElementRef window, CGWindowID *windowID);

#endif

#pragma mark - Getters

AXError AXUIElementGetSize(AXUIElementRef element, CGSize *size);
AXError AXUIElementGetOrigin(AXUIElementRef element, CGPoint *origin);
AXError AXUIElementGetFrame(AXUIElementRef element, CGRect *frame);
AXError AXUIElementCopyWindowAtPosition(CGPoint position, AXUIElementRef *window);
AXError AXUIElementGetTitle(AXUIElementRef element, CFStringRef *title);

#pragma mark - Setters

AXError AXUIElementSetSize(AXUIElementRef element, CGSize size);
AXError AXUIElementSetOrigin(AXUIElementRef element, CGPoint origin);
AXError AXUIElementSetFrame(AXUIElementRef element, CGRect frame);
