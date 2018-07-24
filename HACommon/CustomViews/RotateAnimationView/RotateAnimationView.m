//
//  RotateAnimationView.m
//
#import "RotateAnimationView.h"
#import <QuartzCore/QuartzCore.h>

@interface RotateAnimationView ()
@property(nonatomic, strong)UIImageView* rotateImageView;
@end

CGFloat degreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

NSNumber* degreesToNumber(CGFloat degrees)
{
    return [NSNumber numberWithFloat:degreesToRadians(degrees)];
}

@implementation RotateAnimationView
@synthesize hidesWhenStopped;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithCustom];
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithCustom];
    }
    
    return self;
}

#pragma mark - override
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.rotateImageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

#pragma mark - private
- (void) initWithCustom
{
    self.rotateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.rotateImageView];
}

#pragma mark - public
- (void) setImage:(UIImage*)image
{
    self.rotateImageView.image = image;
    
    CALayer* imageLayer = [self.rotateImageView layer];
    [imageLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [imageLayer setContents:(id)[self.rotateImageView.image CGImage]];
    [self.layer addSublayer:imageLayer];
}

- (void)startAnimating
{
    self.hidden = NO;
    
	NSMutableArray *values = [NSMutableArray array];
    [values addObject:degreesToNumber(0)];
    [values addObject:degreesToNumber(180)];
    [values addObject:degreesToNumber(360)];
    
    CAKeyframeAnimation * animation;
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setDuration:1];
    [animation setRepeatCount:10000];
	[animation setValues:values];
    animation.removedOnCompletion = YES;
    [animation setDelegate:self];
    
    CALayer* imageLayer = [self.rotateImageView layer];
    [imageLayer addAnimation:animation forKey:@"rotate"];
}

- (void)stopAnimating
{
    CALayer* imageLayer = [self.rotateImageView layer];
    [imageLayer removeAllAnimations];
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (BOOL)isAnimating
{
    CALayer* imageLayer = [self.rotateImageView layer];
    CAAnimation* animation = [imageLayer animationForKey:@"rotate"];
    
    return (animation != nil);
}

@end