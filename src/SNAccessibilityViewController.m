#import "SNAccessibilityViewController.h"
#import "SNTextView.h"
#import "SNView.h"
#import "SNAppDelegate.h"


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
    [SNAppDelegate openAccessibilityPreferences];
}


@end
