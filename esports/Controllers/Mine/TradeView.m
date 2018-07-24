//
//  TradeView.m
//  esports
//
//  Created by 焦龙 on 2018/6/22.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "TradeView.h"

@interface TradeView ()

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;
@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UITextField *addTF;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIView *resultView;
@property (nonatomic, strong) UILabel *addressLbl;

@property (nonatomic, strong) void (^resultBlock)(NSString *addStr);
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) NSString *amount;

@end

@implementation TradeView

- (instancetype)initWithFrame:(CGRect)frame amount:(NSString *)amount {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.amount = amount;
        [self loadViews];
    }
    return self;
}

- (void)loadViews {
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.topView];
    
    self.rootLayout = [UIView build:self.bottomView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
        
        params.width = kDeviceWidth;
        params.height = 500 + theAppDelegate.bottomOffset;
        
        UILabel *addLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
            params.topMargin = 28;
            
            layout.text = @"Enter your ETH Wallet Address";
            layout.textColor = kColorBlack;
            layout.font = kNormalFont(16);
        }];
        
        self.addTF = [UITextField build:layout config:^(RelativeLayoutParams *params, UITextField *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = addLbl;
            params.topMargin = 14;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 4.0;
            layout.font = kNormalFont(16);
            layout.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
            layout.leftViewMode = UITextFieldViewModeAlways;
            [layout addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        self.nextBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = 120;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = self.addTF;
            params.topMargin = 20;
            
            [layout setTitle:@"NEXT" forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
            layout.backgroundColor = kColorC3CBCF;
            layout.enabled = NO;
            [layout.titleLabel setFont:kNormalFont(16)];
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                self.resultView.hidden = NO;
                self.addressLbl.text = self.addTF.text;
            } forControlEvents:UIControlEventTouchUpInside];
        }];
        
        self.resultView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = MATCH_PARENT;
            
            layout.backgroundColor = kColorWhite;
            layout.hidden = YES;
            
            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 50;
                params.leftMargin = 26;
                
                layout.text = @"Amount:";
                layout.textColor = kColorLightGray;
                layout.font = kNormalFont(16);
            }];
            
            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 50;
                params.leftMargin = 95;
                
                layout.text = self.amount;
                layout.textColor = kColorFA4731;
                layout.font = kNormalFont(16);
            }];
            
            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 82;
                params.leftMargin = 26;
                
                layout.text = @"Address:";
                layout.textColor = kColorLightGray;
                layout.font = kNormalFont(16);
            }];
            
            self.addressLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = MATCH_PARENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 82;
                params.leftMargin = 95;
                params.rightMargin = 26;
                
                layout.text = @"XXX";
                layout.textColor = kColorBlack;
                layout.font = kNormalFont(16);
            }];
            
            [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 10;
                params.leftMargin = 16;
                
                [layout setImage:[UIImage imageNamed:@"icon_left"] forState:UIControlStateNormal];
                [layout setImage:[UIImage imageNamed:@"icon_left"] forState:UIControlStateHighlighted];
                [layout bk_addEventHandler:^(id sender) {
                    self.resultView.hidden = YES;
                } forControlEvents:UIControlEventTouchUpInside];
            }];
            
            [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 10;
                params.alignParentRight = YES;
                params.rightMargin = 16;
                
                [layout setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
                [layout setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateHighlighted];
                [layout bk_addEventHandler:^(id sender) {
                    [self dismiss];
                } forControlEvents:UIControlEventTouchUpInside];
            }];
            
            [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = 120;
                params.height = 48;
                params.centerHorizontal = YES;
                params.topMargin = 130;
                
                [layout setTitle:@"Confirm" forState:UIControlStateNormal];
                [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
                [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
                layout.backgroundColor = kColor31B4FF;
                [layout.titleLabel setFont:kNormalFont(16)];
                layout.layer.cornerRadius = 4.0;
                [layout bk_addEventHandler:^(id sender) {
                    if (self.resultBlock) {
                        NSString *result = self.addressLbl.text;
                        self.resultBlock(result);
                    }
                    [self dismiss];
                } forControlEvents:UIControlEventTouchUpInside];
            }];
        }];
    }];
    
    [self.topView bk_whenTapped:^{
        [self dismiss];
    }];
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(0);
            make.right.equalTo(self).with.offset(0);
            make.bottom.equalTo(self).with.offset(0);
            make.height.mas_equalTo(0);
        }];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(0);
            make.right.equalTo(self).with.offset(0);
            make.top.equalTo(self).with.offset(0);
            make.bottom.equalTo(self.bottomView.mas_top).with.offset(0);
        }];
        
        self.didSetupConstraints = YES;
    }
    
    NSLog(@"updateConstraints");
    
    [super updateConstraints];
    
}

- (void)showWithHandler:(void (^)(NSString *addStr))block {
    self.resultBlock = block;
    
    self.topView.alpha = 0.3;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self bk_performBlock:^(id obj) {
        [self.bottomView.constraints bk_each:^(id obj) {
            NSLayoutConstraint *constraint = obj;
            if (constraint.firstItem == self.bottomView) {
                if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                    [self.rootLayout requestLayout];
                    
                    constraint.constant = 0;
                    [self layoutIfNeeded];
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         constraint.constant = 500 + theAppDelegate.bottomOffset;
                                         [self layoutIfNeeded];
                                     } completion:^(BOOL finished) {
                                         
                                         
                                     }];
                    
                }
            }
        }];
    } afterDelay:0.01];
    
    
}

- (void)dismiss{
    
    self.topView.alpha = 0;
    [self.bottomView.constraints bk_each:^(id obj) {
        NSLayoutConstraint *constraint = obj;
        if (constraint.firstItem == self.bottomView) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     constraint.constant = 0;
                                     [self layoutIfNeeded];
                                 } completion:^(BOOL finished) {
                                     self.resultBlock = nil;
                                     [self removeFromSuperview];
                                 }];
            }
        }
    }];
    
}

- (void)textFieldDidChangeValue:(id)sender {
    if (![((UITextField *)sender).text isEqualToString:@""]) {
        self.nextBtn.backgroundColor = kColor31B4FF;
        self.nextBtn.enabled = YES;
    } else {
        self.nextBtn.backgroundColor = kColorC3CBCF;
        self.nextBtn.enabled = NO;
    }
}

@end
