//
//  UIImageView+Animation.m
//  fishing
//
//  Created by jslsxu on 15/7/19.
//  Copyright (c) 2015年 mahua. All rights reserved.
//

#import "UIImageView+Animation.h"

@implementation UIImageView (Animation)
-(void)setImageWithFadein:(UIImage *)image
{
    
    if (self.image != image)
    {
        if (self.image == nil)
        {
            CGRect rc = self.frame;
            rc.origin = CGPointZero;
            UIImageView *tmpCover = [[UIImageView alloc] initWithFrame:rc];
            tmpCover.backgroundColor = [UIColor clearColor];
            tmpCover.autoresizingMask = self.autoresizingMask;
            tmpCover.contentMode = self.contentMode;
            tmpCover.image = image;
            [self addSubview:tmpCover];
            [self bringSubviewToFront:tmpCover];
            
            tmpCover.alpha = 0;
            [UIView animateWithDuration:0.7 animations:^
             {
                 tmpCover.alpha = 1;
             }
                             completion:^(BOOL finished)
             {
                 self.image = tmpCover.image;
                 [tmpCover removeFromSuperview];
             }];
        }
        else
        {
            CGRect rc = self.frame;
            rc.origin = CGPointZero;
            UIImageView *tmpCover = [[UIImageView alloc] initWithFrame:rc];
            tmpCover.backgroundColor = [UIColor clearColor];
            tmpCover.autoresizingMask = self.autoresizingMask;
            tmpCover.contentMode = self.contentMode;
            tmpCover.image = self.image;
            [self addSubview:tmpCover];
            [self bringSubviewToFront:tmpCover];
            
            self.image = image;
            [UIView animateWithDuration:0.7 animations:^
             {
                 tmpCover.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 [tmpCover removeFromSuperview];
             }];
        }
    }
}

@end
