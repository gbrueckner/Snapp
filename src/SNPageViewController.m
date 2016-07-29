#import "SNPageViewController.h"
#import "SNView.h"


@interface SNPageViewController ()

@property(readonly) NSMutableArray *leftConstraints;
@property NSLayoutConstraint *heightConstraint;
@property NSLayoutConstraint *widthConstraint;
@property NSUInteger indexOfCurrentViewController;
@property CGFloat maxWidth;

@end


@implementation SNPageViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil {

    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _leftConstraints = [[NSMutableArray alloc] init];
    }

    return self;
}


- (void)dealloc {
    [_leftConstraints release];
    [super dealloc];
}


- (void)loadView {

    self.view = [[SNView alloc] initWithFrame:NSZeroRect];

    [self.view setContentHuggingPriority:NSLayoutPriorityDefaultHigh
                          forOrientation:NSLayoutConstraintOrientationVertical];
    [self.view setContentHuggingPriority:NSLayoutPriorityDefaultHigh
                          forOrientation:NSLayoutConstraintOrientationHorizontal];

    for (NSViewController *viewController in self.childViewControllers) {

        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:viewController.view];

        [viewController.view setContentHuggingPriority:NSLayoutPriorityDefaultHigh
                                        forOrientation:NSLayoutConstraintOrientationVertical];
        [viewController.view setContentHuggingPriority:NSLayoutPriorityDefaultHigh
                                        forOrientation:NSLayoutConstraintOrientationHorizontal];

        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:viewController.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:0];
        [self.view addConstraint:leftConstraint];
        [self.leftConstraints addObject:leftConstraint];

        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:viewController.view
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0]];

        self.maxWidth = MAX(self.maxWidth, viewController.view.fittingSize.width);
    }

    self.indexOfCurrentViewController = 0;

    // Move all views beyond the right edge.
    for (NSLayoutConstraint *constraint in self.leftConstraints)
        constraint.constant = self.maxWidth;

    NSViewController *viewController = [self.childViewControllers objectAtIndex:self.indexOfCurrentViewController];
    NSLayoutConstraint *constraint = [self.leftConstraints objectAtIndex:self.indexOfCurrentViewController];
    //constraint.constant = floor((self.maxWidth - viewController.view.fittingSize.width) / 2);
    constraint.constant = 0;

    [viewController.view layoutSubtreeIfNeeded];
    [self.view layoutSubtreeIfNeeded];

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:viewController.view.fittingSize.height];
    [self.view addConstraint:self.heightConstraint];

    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:0
                                                         constant:viewController.view.fittingSize.width];
    [self.view addConstraint:self.widthConstraint];
}


- (void)transitionToViewController:(NSViewController *)viewController animate:(BOOL)animate {

    NSUInteger indexOfToViewController = [self.childViewControllers indexOfObject:viewController];

    if (indexOfToViewController == self.indexOfCurrentViewController)
        return;

    NSLayoutConstraint *toViewConstraint = [self.leftConstraints objectAtIndex:indexOfToViewController];
    NSLayoutConstraint *fromViewConstraint = [self.leftConstraints objectAtIndex:self.indexOfCurrentViewController];

    toViewConstraint.constant = self.indexOfCurrentViewController < indexOfToViewController ? self.maxWidth : -self.maxWidth;

    [NSAnimationContext beginGrouping];

    if (!animate)
        [NSAnimationContext currentContext].duration = 0;

    toViewConstraint.animator.constant = 0;
    self.heightConstraint.animator.constant = viewController.view.fittingSize.height;
    self.widthConstraint.animator.constant = viewController.view.fittingSize.width;
    fromViewConstraint.animator.constant = self.indexOfCurrentViewController < indexOfToViewController ? -self.maxWidth : self.maxWidth;

    [NSAnimationContext endGrouping];

    self.indexOfCurrentViewController = indexOfToViewController;
}


@end
