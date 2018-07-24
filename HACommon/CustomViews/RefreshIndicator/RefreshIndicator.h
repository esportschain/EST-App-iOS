//
//  RefreshIndicator.h
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAModel.h"

@class RefreshIndicator;
@protocol RefreshIndicatorDelegate <NSObject>
@required
- (void)onClickRetryButton:(RefreshIndicator*)indicator;
@end

@interface RefreshIndicator : UIView
@property(nonatomic, weak) id<RefreshIndicatorDelegate> delegate;

- (void)setEmptyText:(NSString*)text;
- (void)showEmptyView;
- (void)showErrorView;
@end