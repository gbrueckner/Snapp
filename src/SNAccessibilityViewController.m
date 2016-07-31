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


#import "SNAccessibilityViewController.h"
#import "NSAppleScript+Additions.h"
#import "SNAppDelegate.h"
#import "SNTextView.h"
#import "SNView.h"


@implementation SNAccessibilityViewController


- (void)loadView {

    self.view = [[SNView alloc] initWithFrame:NSZeroRect];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextView *informativeText = [[SNTextView alloc] initWithFrame:NSZeroRect];
    informativeText.string = @"Snapp requires accessibility features. Please go to System Preferences > Security & Privacy > Accessibility to enable these features.";
    informativeText.drawsBackground = NO;
    informativeText.font = [NSFont systemFontOfSize:12];
    informativeText.selectable = NO;
    informativeText.textColor = [NSColor darkGrayColor];
    [informativeText setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                          forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.view addSubview:informativeText];
    [informativeText release];

    [informativeText setContentHuggingPriority:NSLayoutPriorityDefaultHigh
                                     forOrientation:NSLayoutConstraintOrientationVertical];

    NSButton *openButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    openButton.title = @"Open System Preferences";
    openButton.bezelStyle = NSRoundedBezelStyle;
    openButton.target = self;
    openButton.action = @selector(openButtonClicked:);
    openButton.keyEquivalent = @"\r";
    [self.view addSubview:openButton];
    [openButton release];

    NSDictionary *views = NSDictionaryOfVariableBindings(informativeText, openButton);

    [views enumerateKeysAndObjectsUsingBlock:^(NSString *viewName, NSView *view, BOOL *stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[informativeText]-[openButton]-|"
                                                options:NSLayoutFormatAlignAllCenterX
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[informativeText(<=250)]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[openButton]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];
}


- (void)openButtonClicked:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSAppleScript executeBundledScriptWithName:@"OpenAccessibilityPreferences"];
    });
}


@end
