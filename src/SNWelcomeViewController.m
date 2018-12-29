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


#import "SNWelcomeViewController.h"
#import "SNAppDelegate.h"
#import "SNTextView.h"
#import "SNView.h"


@implementation SNWelcomeViewController


- (void)loadView {

    self.view = [[SNView alloc] initWithFrame:NSZeroRect];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextView *welcomeLabel = [[SNTextView alloc] initWithFrame:NSZeroRect];
    welcomeLabel.string = @"Hi there!";
    welcomeLabel.alignment = NSTextAlignmentCenter;
    welcomeLabel.drawsBackground = NO;
    welcomeLabel.font = [NSFont systemFontOfSize:18];
    welcomeLabel.selectable = NO;
    welcomeLabel.textColor = [NSColor darkGrayColor];
    [self.view addSubview:welcomeLabel];
    [welcomeLabel release];

    NSTextView *welcomeText = [[SNTextView alloc] initWithFrame:NSZeroRect];
    welcomeText.string = @"Snapp usually stays out of your way, which means that there is no icon in your dock or in your menubar. Snapp has only one window, its preferences window. To show the preferences window, launch Snapp twice by simply clicking on its icon.";
    welcomeText.drawsBackground = NO;
    welcomeText.font = [NSFont systemFontOfSize:12];
    welcomeText.selectable = NO;
    welcomeText.textColor = [NSColor darkGrayColor];
    [self.view addSubview:welcomeText];
    [welcomeText release];

    NSButton *okButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    okButton.title = @"OK";
    okButton.bezelStyle = NSBezelStyleRounded;
    okButton.target = self;
    okButton.action = @selector(okButtonClicked:);
    okButton.keyEquivalent = @"\r";
    [self.view addSubview:okButton];
    [okButton release];

    NSDictionary *views = NSDictionaryOfVariableBindings(welcomeLabel, welcomeText, okButton);

    [views enumerateKeysAndObjectsUsingBlock:^(NSString *viewName, NSView *view, BOOL *stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[welcomeLabel]-[welcomeText]-[okButton]-|"
                                                options:NSLayoutFormatAlignAllCenterX
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[welcomeLabel]|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[welcomeText(<=250)]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[okButton]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];
}


- (void)okButtonClicked:(id)sender {
    [(SNAppDelegate *)(NSApp.delegate) setup];
}


@end
