/* Copyright 2016-2018 gbrueckner.
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


#import "SNTextView.h"


@implementation SNTextView


// This method keeps the width equal and changes the height to the minimum value
// required to display the entire text.
- (NSSize)intrinsicContentSize {

    // This method seems to work correctly for non-retina displays, but not for
    // retina displays. The following line is a dirty ad-hoc fix for retina
    // displays and should be replaced by something better.
    self.textContainer.size = NSMakeSize(258, CGFLOAT_MAX);

    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    return [self.layoutManager usedRectForTextContainer:self.textContainer].size;
}


@end
