/* Copyright 2016 gbrueckner.
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
    self.textContainer.size = self.maxSize;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    return [self.layoutManager usedRectForTextContainer:self.textContainer].size;
}


@end
