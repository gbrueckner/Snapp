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


#import "SNPreferencesViewController.h"
#import "NSAttributedString+Hyperlink.h"
#import "NSFont+Additions.h"
#import "SNAppDelegate.h"
#import "SNTextView.h"
#import "SNView.h"
@import ServiceManagement;


@interface SNPreferencesViewController ()

@property NSButton *loginCheckbox;
@property NSButton *playSoundCheckbox;
@property NSButton *updateCheckbox;

@end


@implementation SNPreferencesViewController


- (void)loadView {

    self.view = [[SNView alloc] initWithFrame:NSZeroRect];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    // Create the info label.
    NSTextView *infoLabel = [[SNTextView alloc] initWithFrame:NSZeroRect];
    infoLabel.string = @"Open Snapp twice to show this window.";
    infoLabel.alignment = NSCenterTextAlignment;
    infoLabel.drawsBackground = NO;
    infoLabel.font = [NSFont labelFont];
    infoLabel.selectable = NO;
    infoLabel.textColor = [NSColor darkGrayColor];
    [infoLabel setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                        forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.view addSubview:infoLabel];
    [infoLabel release];

    // Create the login checkbox.
    self.loginCheckbox = [[NSButton alloc] initWithFrame:NSZeroRect];
    self.loginCheckbox.title = @"Open Snapp automatically when you log in";
    self.loginCheckbox.buttonType = NSSwitchButton;
    self.loginCheckbox.target = self;
    self.loginCheckbox.action = @selector(loginCheckboxClicked:);
    [self.view addSubview:self.loginCheckbox];
    [self.loginCheckbox release];

    // Create the sound checkbox.
    self.playSoundCheckbox = [[NSButton alloc] initWithFrame:NSZeroRect];
    self.playSoundCheckbox.title = @"Play a sound when snapping windows";
    self.playSoundCheckbox.buttonType = NSSwitchButton;
    self.playSoundCheckbox.target = self;
    self.playSoundCheckbox.action = @selector(playSoundCheckboxClicked:);
    [self.view addSubview:self.playSoundCheckbox];
    [self.playSoundCheckbox release];

    // Create the update checkbox.
    self.updateCheckbox = [[NSButton alloc] initWithFrame:NSZeroRect];
    self.updateCheckbox.title = @"Check for updates automatically";
    self.updateCheckbox.buttonType = NSSwitchButton;
    self.updateCheckbox.target = self;
    self.updateCheckbox.action = @selector(updateCheckboxClicked:);
#ifndef APP_STORE
    [self.view addSubview:self.updateCheckbox];
#endif
    [self.updateCheckbox release];

    // Create the quit button.
    NSButton *quitButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    quitButton.title = @"Quit Snapp";
    quitButton.bezelStyle = NSRoundedBezelStyle;
    quitButton.target = NSApp;
    quitButton.action = @selector(terminate:);
    quitButton.keyEquivalent = @"q";
    quitButton.keyEquivalentModifierMask = NSCommandKeyMask;
    [self.view addSubview:quitButton];
    [quitButton release];

    // Create the OSS label.
    NSTextView *ossLabel = [[SNTextView alloc] initWithFrame:NSZeroRect];
    NSMutableAttributedString *ossLabelString = [[NSMutableAttributedString alloc] initWithString:@"Snapp is open source software! To learn more, visit the "];
    [ossLabelString appendAttributedString:[NSAttributedString hyperlinkFromString:@"Snapp GitHub repository"
                                   withURL:[SNAppDelegate repositoryURL]]];
    NSAttributedString *dotString = [[NSAttributedString alloc] initWithString:@"."];
    [ossLabelString appendAttributedString:dotString];
    ossLabel.textStorage.attributedString = ossLabelString;
    ossLabel.alignment = NSCenterTextAlignment;
    ossLabel.drawsBackground = NO;
    ossLabel.editable = NO;
    ossLabel.font = [NSFont labelFont];
    ossLabel.textColor = [NSColor darkGrayColor];
    [ossLabel setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                       forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.view addSubview:ossLabel];
    [dotString release];
    [ossLabel release];
    [ossLabelString release];

    // Layout the subviews.
    NSDictionary *views = @{@"infoLabel": infoLabel,
                        @"loginCheckbox": self.loginCheckbox,
                    @"playSoundCheckbox": self.playSoundCheckbox,
                       @"updateCheckbox": self.updateCheckbox,
                           @"quitButton": quitButton,
                             @"ossLabel": ossLabel};

    [views enumerateKeysAndObjectsUsingBlock:^(NSString *viewName, NSView *view, BOOL *stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }];

    {
#ifndef APP_STORE
        NSString *format = @"V:|[infoLabel]-18-[loginCheckbox]-[playSoundCheckbox]-[updateCheckbox]-[quitButton]-[ossLabel]-8-|";
#else
        NSString *format = @"V:|[infoLabel]-18-[loginCheckbox]-[playSoundCheckbox]-[quitButton]-[ossLabel]-8-|";
#endif
        [self.view addConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:format
                                                    options:NSLayoutFormatAlignAllCenterX
                                                    metrics:nil
                                                      views:views]];
    }

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoLabel]|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ossLabel]|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[loginCheckbox]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[playSoundCheckbox]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

#ifndef APP_STORE
    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[updateCheckbox]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];
#endif

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[quitButton]->=0-|"
                                                options:0
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraint:
        [NSLayoutConstraint constraintWithItem:self.loginCheckbox
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.playSoundCheckbox
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1
                                      constant:0]];

#ifndef APP_STORE
    [self.view addConstraint:
        [NSLayoutConstraint constraintWithItem:self.playSoundCheckbox
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.updateCheckbox
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1
                                      constant:0]];
#endif
}


- (void)viewWillAppear {
    self.loginCheckbox.state     = [[NSUserDefaults standardUserDefaults] boolForKey:@"openAtLogin"]     ? NSOnState : NSOffState;
    self.playSoundCheckbox.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSnapSound"]   ? NSOnState : NSOffState;
    self.updateCheckbox.state    = [[NSUserDefaults standardUserDefaults] boolForKey:@"checkForUpdates"] ? NSOnState : NSOffState;
}


- (void)loginCheckboxClicked:(NSButton *)loginCheckbox {

    if (SMLoginItemSetEnabled(CFSTR("com.brueckner.SnappHelper"),
                               loginCheckbox.state == NSOnState ? TRUE : FALSE)) {
         [[NSUserDefaults standardUserDefaults] setBool:(loginCheckbox.state == NSOnState)
                                                 forKey:@"openAtLogin"];
    }
    else
        [loginCheckbox setNextState];
}


- (void)playSoundCheckboxClicked:(NSButton *)playSoundCheckbox {
     [[NSUserDefaults standardUserDefaults] setBool:(playSoundCheckbox.state == NSOnState)
                                             forKey:@"playSnapSound"];
}


- (void)updateCheckboxClicked:(NSButton *)updateCheckbox {
     [[NSUserDefaults standardUserDefaults] setBool:(updateCheckbox.state == NSOnState)
                                             forKey:@"checkForUpdates"];
}


@end
