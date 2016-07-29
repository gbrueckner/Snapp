#import "SNWelcomeViewController.h"
#import "SNTextView.h"
#import "SNView.h"


@implementation SNWelcomeViewController


- (void)loadView {

    self.view = [[SNView alloc] initWithFrame:NSZeroRect];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextView *welcomeLabel = [[SNTextView alloc] initWithFrame:NSZeroRect];
    welcomeLabel.string = @"Hi there!";
    welcomeLabel.alignment = NSCenterTextAlignment;
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
    okButton.bezelStyle = NSRoundedBezelStyle;
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
    [NSApp.delegate setup];
}


@end
