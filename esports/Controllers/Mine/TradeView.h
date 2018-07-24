//
//  TradeView.h
//  esports
//
//  Created by 焦龙 on 2018/6/22.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TradeView : UIView

- (instancetype)initWithFrame:(CGRect)frame amount:(NSString *)amount;
- (void)showWithHandler:(void (^)(NSString *addStr))block;

@end
