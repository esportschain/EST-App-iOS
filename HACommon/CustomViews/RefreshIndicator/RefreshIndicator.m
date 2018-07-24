//
//  RefreshIndicator.h
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "RefreshIndicator.h"
#import "UIView+Layout.h"

@interface RefreshIndicator()
@property(nonatomic, strong) UIView* rootLayout;
@property(nonatomic, strong) UIView* emptyView;
@property(nonatomic, strong) UIView* errorView;
@property(nonatomic, strong) UILabel* emptyLabel;
@end

@implementation RefreshIndicator
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.rootLayout = [UIView build:self container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout){
        params.width = MATCH_PARENT;
        params.height = MATCH_PARENT;
        
        UIView* centerView = [UIView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
            params.width = 1;
            params.height = 1;
            params.centerHorizontal = YES;
            params.centerVertical = YES;
            
            [layout setBackgroundColor:[UIColor clearColor]];
        }];
        
        self.emptyView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
//            params.centerVertical = YES;
            params.alignBottom = centerView;
            
            UIImageView *imageView = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                params.width = 120;
                params.height = 36;
                params.centerHorizontal = YES;
                
                layout.image = [UIImage imageNamed:@"logo.png"];
            }];
            
//            self.emptyLabel = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
//                params.width = WRAP_CONTENT;
//                params.height = WRAP_CONTENT;
//                params.belowOf = imageView;
//                params.topMargin = 15;
//                params.centerHorizontal = YES;
//                
//                layout.text = @"暂无数据, 稍后再来吧";
//                layout.textColor = kColor999999;
//                layout.font = kNormalFont(16);
//            }];
        }];
        
        self.errorView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
//            params.centerVertical = YES;
            params.alignBottom = centerView;
            
            [layout addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorViewClick)]];
            
            UIImageView *imageView = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                params.width = 50;
                params.height = 50;
                params.centerHorizontal = YES;
                
                layout.image = [UIImage imageNamed:@"loading_failure.png"];
            }];
            
//            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
//                params.width = WRAP_CONTENT;
//                params.height = WRAP_CONTENT;
//                params.belowOf = imageView;
//                params.topMargin = 20;
//                params.centerHorizontal = YES;
//                
//                layout.text = @"加载失败, 请点击重试";
//                layout.textColor = kColorNavButton;
//                layout.font = kNormalFont(16);
//            }];
        }];
    }];
    
    [self.rootLayout requestLayout];
    
    self.hidden = YES;
}

- (void)errorViewClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickRetryButton:)]) {
        [self.delegate onClickRetryButton:self];
    }
}

- (void)setEmptyText:(NSString*)text
{
    [self.emptyLabel setText:text];
    
    [self.rootLayout requestLayout];
}

- (void)showEmptyView
{
    self.hidden = NO;
    self.emptyView.hidden = NO;
    self.errorView.hidden = YES;
}

- (void)showErrorView
{
    self.hidden = NO;
    self.emptyView.hidden = YES;
    self.errorView.hidden = NO;
}

@end
