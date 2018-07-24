//
//  BaseTableViewController.h
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
#import "HATableViewCell.h"
#import "RefreshIndicator.h"
#import "HAHttpTask.h"
#import "HATableViewAdapter.h"
#import "MJRefresh.h"

/**
 * BaseTableViewControllerConfig
 */
@protocol BaseTableViewControllerConfig <NSObject>
@property(nonatomic, strong, readonly) HATableViewAdapter* adapter;
@property(nonatomic, strong, readonly) MJRefreshHeader* refreshHeader;
@property(nonatomic, strong, readonly) MJRefreshFooter* refreshFooter;
@property(nonatomic, strong, readonly) RefreshIndicator* refreshIndicator;

@required
- (HAListModel*)requireListModel;
- (Class<HATableViewCell>)requireCellClass;
- (HATableViewAdapter*)requireAdapter;
- (MJRefreshHeader*)requireRefreshHeader;
- (MJRefreshFooter*)requireRefreshFooter;
- (RefreshIndicator*)requireRefreshIndicator;

- (void)didTriggerPullDownRefresh;
- (void)didTriggerPullUpRefresh;
@end

/**
 * BaseTableViewController
 */
@interface BaseTableViewController : BaseViewController<BaseTableViewControllerConfig, HAHttpTaskBuildParamsFilter, HAHttpTaskEnterQueueFilter, HAHttpTaskSucceededFilter, HAHttpTaskFailedFilter, HAHttpTaskCanceledFilter, RefreshIndicatorDelegate, HATableViewDelegate, HATableViewCellDelegate>
@property(nonatomic, strong, readonly) UITableView* tableView;
//@property(nonatomic, strong) NSString* nextPage;

@property(nonatomic, strong) NSString* page;
@property(nonatomic, assign) BOOL isEnd;

- (void)refreshData:(BOOL)clearOldData complete:(HAHttpTaskCompletedBlock)completeBlock;

// 根据url获取缓存数据
- (void)getCacheData:(HAHttpTaskCompletedBlock)completeBlock;

@end
