//
//  HATableViewCell.h
//  aimdev
//
//  Created by dongjianbo on 15-1-4.
//  Copyright 2015 www.aimdev.cn
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import <UIKit/UIKit.h>
#import "HAModel.h"
#import "HAViewModel.h"
#import "UIView+Layout.h"

/**
 * HATableViewCell
 */
@protocol HATableViewCell <NSObject>
@end

/**
 * HATableViewCellDelegate
 */
@protocol HATableViewCellDelegate <NSObject>
@end

/**
 * HATableViewCellDelegate
 */
@protocol HATableViewCellHeight <NSObject>
// 避免重复计算cell高度，导致CPU占用过高
// 如果动态改变过里面的内容，如新加评论等，需将此值重置为0或[UITableView reloadData](在onModelToUI里重新计算cellHeight)
@property(nonatomic, assign) CGFloat cellHeight;
@end

/**
 * HATableViewCell
 */
@interface HATableViewCell : UITableViewCell<HATableViewCell, HAViewModel>

// cell事件代理
@property (nonatomic, weak) id<HATableViewCellDelegate> delegate;

// 关联的model
@property(nonatomic, strong, readonly) HAModel* model;

// 数据转换为UI显示
- (void)onModelToUI:(HAModel*)model;

// 从modelItem计算cell的高度，如在onModelToUI里设置了cell的高度，则不用实现此方法
+ (NSNumber*)cellHeight:(HAModel*)model cellWidth:(CGFloat)width;

#if DEBUG
// 放一个UI参考图，用于比较实际实现的UI与设计UI差别
- (void) setDesignImage:(UIImage*)image;
#endif

@end
