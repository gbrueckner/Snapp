@import AppKit;
@class SNChildViewController;


@interface SNViewController : NSViewController


- (void)transitionToPreferencesViewController:(id)sender;
- (void)transitionToAccessibilityViewController:(id)sender;
- (void)transitionToUpdateViewController:(id)sender;


@end
