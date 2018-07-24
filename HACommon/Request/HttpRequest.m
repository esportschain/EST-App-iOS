//
//  HttpRequest.m
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

#import "HttpRequest.h"
#import "HttpTaskCommonParamsFilter.h"
#import "HttpTaskXAuthFilter.h"
#import "HttpTaskParserFilter.h"
#import "HttpTaskCacheFilter.h"
#import "HttpTaskFailedFilter.h"
#import "HAStringUtil.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation HttpRequest
SYNTHESIZE_SINGLETON_FOR_CLASS(HttpRequest);

-(HAHttpTask*)makeTask:(id)canceler path:(NSString*)path
{
    HAHttpTask* task = [HAHttpTask task];
    task.request.url = MAIN_API_URL(path);
    task.canceler = canceler;
    task.request.method = HttpMethodGet;
    
    [task addFilter:[HttpTaskCommonParamsFilter sharedInstance]];
    [task addFilter:[HttpTaskParserFilter sharedInstance]];
    [task addFilter:[HttpTaskCacheFilter sharedInstance]];
    [task addFilter:[HttpTaskFailedFilter sharedInstance]];
    
    return task;
}

-(void)getCacheData:(HAHttpTask *)task complete:(HAHttpTaskCompletedBlock)completeBlock
{
    if (completeBlock) {
        HAHttpTaskCompletedBlockFilter* completedBlockFilter = [[HAHttpTaskCompletedBlockFilter alloc] init];
        completedBlockFilter.block = completeBlock;
        [task addFilter:completedBlockFilter];
    }
    
    // 构建参数
    [task notifyTaskStatusChanged:HttpTaskStatusBuildParams];
    
    // 读取cache file
    NSString* cacheFilePath = [NSString stringWithFormat:@"%@/%@", kPathUrlCache, [HAStringUtil md5:[task getCacheUrl]]];
    NSData* data = [NSData dataWithContentsOfFile:cacheFilePath];
    
    // 在这把method修改为HttpMethodGetCache，可以根据此值判断task是否为取缓存操作
    task.request.method = HttpMethodGetCache;
    
    // 设置task response
    task.response.statusCode = 200;
    task.response.contentLength = [data length];
    task.response.data = data;
    [task notifyTaskStatusChanged:HttpTaskStatusSucceeded];
}

- (void)execute:(HAHttpTask*)task complete:(HAHttpTaskCompletedBlock)completeBlock
{
    // XAuth签名需要在最后一个构建参数处执行
    [task addFilter:[HttpTaskXAuthFilter sharedInstance]];
    [super execute:task complete:completeBlock];
}

@end
