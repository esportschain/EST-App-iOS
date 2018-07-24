//
//  HAHttpTaskExecutor.h
//  HoneyAnt
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

#import <Foundation/Foundation.h>
#import "HAObject.h"
#import "HAHttpTask.h"

#define kHttpLogError      1 // 是否记录错误事件
#define kHttpLogRequest    0 // 是否记录请求事件
#define kHttpLogResponse   0 // 是否记录响应事件

#ifdef DEBUG
#define HttpLog(fmt, ...) NSLog((@"DLog --- %s [Line %d] \n\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define HttpLog_Condition(condition, xx, ...) {if((condition)) {HttpLog(xx, ##__VA_ARGS__);}} ((void)0)
#else
#define HttpLog(...)
#define HttpLog_Condition(condition, xx, ...) ((void)0)
#endif

/**
 * http任务完成状态监测
 */
typedef void (^HAHttpTaskCompletedBlock)(HAHttpTask* task);


@interface HAHttpTaskCompletedBlockFilter : NSObject<HAHttpTaskCompletedFilter>
@property(nonatomic, copy) HAHttpTaskCompletedBlock block;
@end

/**
 * HAHttpTaskExecutor
 */
@interface HAHttpTaskExecutor : HAObject

// 设置最大并发数，默认为4
- (void)setMaxOperationCount:(NSInteger)count;

// 设置超时时间
- (void)setTimeout:(NSInteger)timeout;       // 默认为30s

// 设置重试次数
- (void)setRetryCount:(NSInteger)retryCount; // 默认为1

// 将网络任务加入请求队列并执行
- (void)execute:(HAHttpTask*)task complete:(HAHttpTaskCompletedBlock)completeBlock;

// 取消网络任务
- (void)cancelTaskByIndex:(NSInteger)index;
- (void)cancelTaskByFlag:(NSString*)flag;
- (void)cancelTaskByCanceler:(id)cancler;
- (void)cancelAllTask;

@end
