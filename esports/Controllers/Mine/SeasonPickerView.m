//
//  SeasonPickerView.m
//  esports
//
//  Created by 焦龙 on 2018/6/21.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "SeasonPickerView.h"

@interface SeasonPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *submitBtn;

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) void (^resultBlock)(NSString * selectedId);


@property (strong, nonatomic) UIPickerView *seasonPicker;
@property (strong, nonatomic) NSString *selectedId;
@property (strong, nonatomic) NSArray *seasonArr;

@end

@implementation SeasonPickerView

- (instancetype)initWithFrame:(CGRect)frame seasonArr:(NSArray *)seasonArr selectedId:(NSString *)selectedId {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.seasonArr = [NSArray arrayWithArray:seasonArr];
        self.selectedId = selectedId;
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
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:kColor31B4FF forState:UIControlStateNormal];
    self.cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.bottomView addSubview:self.cancelBtn];
    
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitBtn.backgroundColor = [UIColor clearColor];
    [self.submitBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:kColor31B4FF forState:UIControlStateNormal];
    self.submitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.bottomView addSubview:self.submitBtn];
    
    
    self.seasonPicker = [[UIPickerView alloc] init];
    self.seasonPicker.backgroundColor = [UIColor whiteColor];
    self.seasonPicker.dataSource = self;
    self.seasonPicker.delegate = self;
    [self addSubview:self.seasonPicker];
    
    //设置pickerview初始默认
    if ([self.selectedId length]) {
        for (int i = 0; i < [self.seasonArr count]; i++) {
            if ([[[self.seasonArr objectAtIndex:i] objectForKey:@"id"] isEqualToString:self.selectedId]) {
                [self.seasonPicker selectRow:i inComponent:0 animated:NO];
            }
        }
    }
    
    [self.topView bk_whenTapped:^{
        [self dismiss];
    }];
    
    [self.cancelBtn bk_addEventHandler:^(id sender) {
        [self dismiss];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.submitBtn bk_addEventHandler:^(id sender) {
        if (self.resultBlock) {
            NSString *result = self.selectedId;
            self.resultBlock(result);
        }
        [self dismiss];
    } forControlEvents:UIControlEventTouchUpInside];
    
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
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView).with.offset(10);
            make.left.equalTo(self.bottomView).with.offset(20);
            make.size.mas_equalTo(CGSizeMake(100, 25));
        }];
        
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView).with.offset(10);
            make.right.equalTo(self.bottomView).with.offset(-20);
            make.size.mas_equalTo(CGSizeMake(100, 25));
        }];
        
        
        [self.seasonPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cancelBtn.mas_bottom).with.offset(0);
            make.left.equalTo(self.bottomView).with.offset(10);
            make.right.equalTo(self.bottomView).with.offset(-10);
        }];
        
        
        self.didSetupConstraints = YES;
    }
    
    NSLog(@"updateConstraints");
    
    [super updateConstraints];
    
}

- (void)showWithHandler:(void (^)(NSString *selectedId))block {
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
                    constraint.constant = 0;
                    [self layoutIfNeeded];
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         constraint.constant = 215 + theAppDelegate.bottomOffset;
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


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.seasonArr count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedId = [self.seasonArr[row] objectForKey:@"id"];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.seasonArr[row] objectForKey:@"name"];
}

@end
