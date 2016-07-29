@import AppKit;
#import "SNViewController.h"


@interface SNChildViewController : NSViewController


@property(readonly) SNViewController *mainViewController;


- (instancetype)initWithMainViewController:(SNViewController *)mainViewController;


@end
