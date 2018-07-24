//
//  LZTabBarButton.m
//  LianZhiParent
//
//  Created by jslsxu on 14/12/22.
//  Copyright (c) 2014年 jslsxu. All rights reserved.
//

#import "LZTabBarButton.h"

@interface LZTabBarButton()
@property(nonatomic, strong)UIImageView* redDot;
@end

@implementation LZTabBarButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.titleLabel.text.length > 0) {
        self.titleLabel.font = kNormalFont(12);
        self.imageView.contentMode = UIViewContentModeCenter;
        
        CGFloat spacing = 2.5;
        
        // lower the text and push it left so it appears centered
        //  below the image
        CGSize imageSize = self.imageView.frame.size;
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        CGSize titleSize = self.titleLabel.frame.size;
        self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    }
    else {
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
    }
    
    if(self.redDot == nil) {
        self.redDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(@"new_msg_bg.png")]];
        [self addSubview:self.redDot];
        [self.redDot setHidden:YES];
    }
    
    [self.redDot setCenter:CGPointMake(self.width - 20, 12)];
}

- (void)setHasNew:(BOOL)hasNew
{
    _hasNew = hasNew;
    [self.redDot setHidden:!_hasNew];
}

@end
