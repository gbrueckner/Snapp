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


#import "SNUpdateViewController.h"
#import "SNTextView.h"
#import "SNView.h"
#import "SNAppDelegate.h"


@interface SNUpdateViewController ()

@property NSButton *yesButton;

@end


@implementation SNUpdateViewController


- (void)loadView {

    self.view = [[SNView alloc] initWithFrame:NSZeroRect];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextView *informativeText = [[SNTextView alloc] initWithFrame:NSZeroRect];
    informativeText.string = @"There's a new version of Snapp available! Would you like to visit Snapp's GitHub repository to update?";
    informativeText.drawsBackground = NO;
    informativeText.font = [NSFont systemFontOfSize:12];
    informativeText.selectable = NO;
    informativeText.textColor = [NSColor darkGrayColor];
    [informativeText setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                          forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.view addSubview:informativeText];
    [informativeText release];

    self.yesButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    self.yesButton.title = @"Yes";
    self.yesButton.bezelStyle = NSBezelStyleRounded;
    self.yesButton.target = self;
    self.yesButton.action = @selector(buttonClicked:);
    self.yesButton.keyEquivalent = @"\r";

    NSButton *noButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    noButton.title = @"No";
    noButton.bezelStyle = NSBezelStyleRounded;
    noButton.target = self;
    noButton.action = @selector(buttonClicked:);
    noButton.keyEquivalent = @"\E";

    NSView *buttonsContainer = [[NSView alloc] initWithFrame:NSZeroRect];
    [buttonsContainer addSubview:self.yesButton];
    [buttonsContainer addSubview:noButton];
    [self.view addSubview:buttonsContainer];
    [self.yesButton release];
    [noButton release];
    [buttonsContainer release];

    NSDictionary *views = @{@"informativeText": informativeText,
                                  @"yesButton": self.yesButton,
                                   @"noButton": noButton,
                           @"buttonsContainer": buttonsContainer};

    [views enumerateKeysAndObjectsUsingBlock:^(NSString *viewName, NSView *view, BOOL *stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[informativeText]-[buttonsContainer]-|"
                                                options:NSLayoutFormatAlignAllCenterX
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[informativeText(<=250)]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[buttonsContainer]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];
    [buttonsContainer addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[yesButton]-[noButton]|"
                                                options:NSLayoutFormatAlignAllCenterY
                                                metrics:nil
                                                  views:views]];
    [buttonsContainer addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[yesButton]|"
                                                options:0
                                                metrics:nil
                                                  views:views]];
    [buttonsContainer addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noButton]|"
                                                options:0
                                                metrics:nil
                                                  views:views]];
}


- (void)buttonClicked:(id)sender {
    [(SNAppDelegate *)(NSApp.delegate) userWantsUpdate:[sender isEqual:self.yesButton]];
}


@end
