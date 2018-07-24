//
//  RotateAnimationView.h
//

#import <UIKit/UIKit.h>

@interface RotateAnimationView : UIView

@property(nonatomic, assign) BOOL hidesWhenStopped;

- (void) setImage:(UIImage*)image;
- (void) startAnimating;
- (void) stopAnimating;
- (BOOL) isAnimating;

@end
