//
//  BaseTableViewController.m
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

#import "BaseTableViewController.h"
#import "UIView+Layout.h"
#import "HttpTaskClearModelItemsFilter.h"

@interface BaseTableViewController ()
@end

@implementation BaseTableViewController
@synthesize adapter = _adapter;
@synthesize refreshHeader = _refreshHeader;
@synthesize refreshFooter = _refreshFooter;
@synthesize refreshIndicator = _refreshIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:kRootViewColor];
    
    self.page = @"1";
    
    // adapter
    _adapter = [self requireAdapter];
    _adapter.listModel = [self requireListModel];
    _adapter.cellClass = [self requireCellClass];
    
    // table view
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setBackgroundColor:kRootViewColor];
    _tableView.delegate = _adapter;
    _tableView.dataSource = _adapter;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    // refresh header
    _refreshHeader = [self requireRefreshHeader];
    if (_refreshHeader) {
        [_tableView addSubview:_refreshHeader];
    }
    
    // refresh footer
    _refreshFooter = [self requireRefreshFooter];
    
    // refresh indicator
    _refreshIndicator = [self requireRefreshIndicator];
    if (_refreshIndicator) {
        [_tableView addSubview:_refreshIndicator];
    }
    
    [self.refreshHeader beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.adapter.listModel.modelItems count] <= 0 && ![self.refreshHeader isRefreshing]) {
        [self.refreshHeader beginRefreshing];
    }
}

#pragma mark - BaseTableViewControllerConfig
- (HAListModel*)requireListModel
{
    NSAssert(NO, @"在继承类中实现");
    
    return nil;
}

- (Class<HATableViewCell>)requireCellClass
{
    NSAssert(NO, @"在继承类中实现");
    
    return nil;
}

- (HATableViewAdapter*)requireAdapter
{
    // default HATableViewAdapter
    HATableViewAdapter* adapter = [[HATableViewAdapter alloc] init];
    adapter.tableViewDelegate = self;
    adapter.cellDelegate = self;
    return adapter;
}

- (MJRefreshHeader*)requireRefreshHeader
{
    // default MJRefreshNormalHeader
    MJRefreshNormalHeader* refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(didTriggerPullDownRefresh)];
    refreshHeader.y = -refreshHeader.height;
    
    return refreshHeader;
}

- (MJRefreshFooter*)requireRefreshFooter
{
    // default MJRefreshAutoNormalFooter
    MJRefreshAutoNormalFooter* refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(didTriggerPullUpRefresh)];
    refreshFooter.pullingPercent = 0.0f;
    
    return refreshFooter;
}

- (RefreshIndicator*)requireRefreshIndicator
{
    // default RefreshIndicator
    RefreshIndicator* refreshIndicator = [[RefreshIndicator alloc] initWithFrame:self.tableView.bounds];
    refreshIndicator.delegate = self;
    
    return refreshIndicator;
}

- (void)didTriggerPullDownRefresh
{
    [self refreshData:YES complete:nil];
}

- (void)didTriggerPullUpRefresh
{
    [self refreshData:NO complete:nil];
}

#pragma mark - RefreshIndicatorDelegate
- (void)onClickRetryButton:(RefreshIndicator*)indicator
{
    if (self.refreshHeader) {
        [self.refreshHeader beginRefreshing];
    }
    else {
        [self refreshData:YES complete:nil];
    }
}

#pragma mark - HAHttpTaskFilter
- (void)onHAHttpTaskBuildParamsFilterExecute:(HAHttpTask*)task
{
//    if (self.nextPage) {
//        [task.request.params setValue:self.nextPage forKey:@"nextpage"];
//    }
    
    if (![self.page isEqualToString:@"1"]) {
        [task.request.params setValue:self.page forKey:@"page"];
        task.request.method = HttpMethodPost;
    }
}

- (void)onHAHttpTaskEnterQueueFilterExecute:(HAHttpTask*)task
{
    if (self.refreshIndicator) {
        self.refreshIndicator.hidden = YES;
    }
}

- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    if (self.refreshHeader) {
        [self.refreshHeader endRefreshing];
    }
    
    if (self.refreshFooter) {
        [self.refreshFooter endRefreshing];
    }
    
    HttpResult* result = (HttpResult*)task.result;
    if (result.code == HTTP_RESULT_SUCCESS) {
//        self.nextPage = [result.data stringForKey:@"nextpage"];
        
        self.isEnd = [result.data boolForKey:@"isEnd"];
        
        if (self.refreshIndicator) {
            if ([self.adapter.listModel.modelItems count] <= 0) {
                [self.refreshIndicator showEmptyView];
            }
            else {
                self.refreshIndicator.hidden = YES;
            }
        }
        
        if (self.refreshFooter) {
            if (!self.isEnd && [self.adapter.listModel.modelItems count] > 0) {
                self.tableView.tableFooterView = self.refreshFooter;
            }
            else {
                self.tableView.tableFooterView = nil;
            }
        }
    }
    else {
        if (self.refreshIndicator) {
            self.refreshIndicator.hidden = YES;
        }
    }
    
    [self.tableView reloadData];
}

- (void)onHAHttpTaskFailedFilterExecute:(HAHttpTask*)task
{
    if (self.refreshHeader) {
        [self.refreshHeader endRefreshing];
    }
    
    if (self.refreshFooter) {
        [self.refreshFooter endRefreshing];
    }
    
    if (self.refreshIndicator) {
        if ([self.adapter.listModel.modelItems count] <= 0) {
            [self.refreshIndicator showErrorView];
        }
        else {
            self.refreshIndicator.hidden = YES;
        }
    }
}

- (void)onHAHttpTaskCanceledFilterExecute:(HAHttpTask*)task
{
    if (self.refreshHeader) {
        [self.refreshHeader endRefreshing];
    }
    
    if (self.refreshFooter) {
        [self.refreshFooter endRefreshing];
    }
    
    if (self.refreshIndicator) {
        self.refreshIndicator.hidden = YES;
    }
}

#pragma mark - public
- (void)refreshData:(BOOL)clearOldData complete:(HAHttpTaskCompletedBlock)completeBlock
{
    if (self.refreshIndicator) {
        self.refreshIndicator.hidden = YES;
    }
    
    HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:self path:nil];
    
    // 清除旧数据
    if (clearOldData) {
//        self.nextPage = nil;
        self.page = @"1";
        
        self.adapter.listModel.page = self.page;
        
        HttpTaskClearModelItemsFilter* clearModelItemsFilter = [[HttpTaskClearModelItemsFilter alloc] init];
        clearModelItemsFilter.listModel = self.adapter.listModel;
        [task addFilter:clearModelItemsFilter];
    } else {
        int next = [self.page intValue] + 1;
        self.page = [NSString stringWithFormat:@"%d", next];
        
        self.adapter.listModel.page = self.page;
        
        HttpTaskClearModelItemsFilter* clearModelItemsFilter = [[HttpTaskClearModelItemsFilter alloc] init];
        clearModelItemsFilter.listModel = self.adapter.listModel;
        [task addFilter:clearModelItemsFilter];
    }
    
    if ([self.adapter.listModel conformsToProtocol:@protocol(HAHttpTaskFilter)]) {
        id<HAHttpTaskFilter> taskModelFilter = (id<HAHttpTaskFilter>)self.adapter.listModel;
        [task addFilter:taskModelFilter];
    }
    
    [task addFilter:self];
    [[HttpRequest sharedInstance] execute:task complete:completeBlock];
}

- (void)getCacheData:(HAHttpTaskCompletedBlock)completeBlock
{
    HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:self path:nil];
    
    // 清除旧数据
//    self.nextPage = nil;
    self.page = @"1";
    
    self.adapter.listModel.page = self.page;
    
    HttpTaskClearModelItemsFilter* clearModelItemsFilter = [[HttpTaskClearModelItemsFilter alloc] init];
    clearModelItemsFilter.listModel = self.adapter.listModel;
    [task addFilter:clearModelItemsFilter];
    
    if ([self.adapter.listModel conformsToProtocol:@protocol(HAHttpTaskFilter)]) {
        id<HAHttpTaskFilter> taskModelFilter = (id<HAHttpTaskFilter>)self.adapter.listModel;
        [task addFilter:taskModelFilter];
    }
    
    [task addFilter:self];
    [[HttpRequest sharedInstance] getCacheData:task complete:completeBlock];
}

@end
