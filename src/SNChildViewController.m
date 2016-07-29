#import "SNChildViewController.h"
#import "SNViewController.h"


@implementation SNChildViewController


- (instancetype)initWithMainViewController:(SNViewController *)mainViewController {

    if ((self = [super init]))
        _mainViewController = [mainViewController retain];

    return self;
}


- (void)dealloc {
    [_mainViewController release];
    [super dealloc];
}


@end
