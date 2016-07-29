#import "SNUpdateViewController.h"
#import "SNTextView.h"
#import "SNView.h"
#import "SNAppDelegate.h"


@interface SNUpdateViewController ()

@property(assign) NSButton *yesButton;

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
    self.yesButton.bezelStyle = NSRoundedBezelStyle;
    self.yesButton.target = self;
    self.yesButton.action = @selector(buttonClicked:);
    self.yesButton.keyEquivalent = @"\r";

    NSButton *noButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    noButton.title = @"No";
    noButton.bezelStyle = NSRoundedBezelStyle;
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
    [NSApp.delegate shouldUpdate:[sender isEqual:self.yesButton]];
    //[[NSWorkspace sharedWorkspace] openURL:[SNAppDelegate repositoryURL]];
    //[self.mainViewController transitionToPreferencesViewController:self];
}


@end
