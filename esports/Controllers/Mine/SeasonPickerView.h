//
//  SeasonPickerView.h
//  esports
//
//  Created by 焦龙 on 2018/6/21.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeasonPickerView : UIView

- (instancetype)initWithFrame:(CGRect)frame seasonArr:(NSArray *)seasonArr selectedId:(NSString *)selectedId;
- (void)showWithHandler:(void (^)(NSString *selectedId))block;

@end
