#import "SNViewController.h"
#import "SNChildViewController.h"
#import "SNWelcomeViewController.h"
#import "SNAccessibilityViewController.h"
#import "SNPreferencesViewController.h"
#import "SNUpdateViewController.h"
#import "SNPageViewController.h"
#import <GBVersionTracking/GBVersionTracking.h>


@interface SNViewController ()

@property SNPageViewController *pageViewController;
@property SNAccessibilityViewController *accessibilityViewController;
@property SNPreferencesViewController *preferencesViewController;
@property SNUpdateViewController *updateViewController;
@property SNWelcomeViewController *welcomeViewController;

@end


@implementation SNViewController


- (void)loadView {

    self.view = [[NSVisualEffectView alloc] initWithFrame:NSZeroRect];

    // Create the icon view.
    NSImageView *iconView = [[NSImageView alloc] initWithFrame:NSZeroRect];
    iconView.image = [NSApp applicationIconImage];
    iconView.image.size = NSMakeSize(128, 128);
    [iconView setContentHuggingPriority:NSLayoutPriorityDefaultHigh
                         forOrientation:NSLayoutConstraintOrientationVertical];
    [self.view addSubview:iconView];
    [iconView release];

    self.welcomeViewController = [[SNWelcomeViewController alloc] initWithMainViewController:self];
    self.accessibilityViewController = [[SNAccessibilityViewController alloc] initWithMainViewController:self];
    self.preferencesViewController = [[SNPreferencesViewController alloc] initWithMainViewController:self];
    self.updateViewController = [[SNUpdateViewController alloc] initWithMainViewController:self];

    self.pageViewController = [[SNPageViewController alloc] initWithNibName:nil
                                                                     bundle:nil];

    [self.pageViewController addChildViewController:self.welcomeViewController];
    [self.pageViewController addChildViewController:self.accessibilityViewController];
    [self.pageViewController addChildViewController:self.preferencesViewController];
    [self.pageViewController addChildViewController:self.updateViewController];

    [self.view addSubview:self.pageViewController.view];

    NSDictionary *views = @{@"iconView": iconView,
                            @"pageView": self.pageViewController.view};

    [views enumerateKeysAndObjectsUsingBlock:^(NSString *viewName, NSView *view, BOOL *stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }];

    [self.view addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[iconView]-[pageView]|"
                                                options:NSLayoutFormatAlignAllCenterX
                                                metrics:nil
                                                  views:views]];

    [self.view addConstraints:
          [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[iconView]-|"
                                                  options:0
                                                  metrics:nil
                                                    views:views]];

    [self.view addConstraints:
          [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[pageView]-|"
                                                  options:0
                                                  metrics:nil
                                                    views:views]];

    /*NSViewController *activeViewController = self.preferencesViewController;
    if ([GBVersionTracking isFirstLaunchForVersion])
        activeViewController = self.welcomeViewController;
    [self.pageViewController transitionToViewController:activeViewController
                                                animate:NO];*/
}


- (void)transitionToPreferencesViewController:(id)sender {
    [self.pageViewController transitionToViewController:self.preferencesViewController
                                                animate:self.pageViewController.view.window.visible];
}


- (void)transitionToAccessibilityViewController:(id)sender {
    [self.pageViewController transitionToViewController:self.accessibilityViewController
                                                animate:self.pageViewController.view.window.visible];
}


- (void)transitionToUpdateViewController:(id)sender {
    [self.pageViewController transitionToViewController:self.updateViewController
                                                animate:self.pageViewController.view.window.visible];
}


@end
