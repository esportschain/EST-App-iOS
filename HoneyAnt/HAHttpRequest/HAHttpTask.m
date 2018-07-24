//
//  HAHttpTask.m
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

#import "HAHttpTask.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static NSInteger sHttpTaskindex = 0;

/**
 * form表单提交的数据，放到HAHttpTaskRequest的params里
 */
@implementation HAFormPost

@end

/**
 * form表单提交的数据，放到HAHttpTaskRequest的params里
 */
@implementation HAFormPostData

@end

/**
 * form表单提交的文件，放到HAHttpTaskRequest的params里
 */
@implementation HAFormPostFile

@end

/**
 * 请求参数
 */
@implementation HAHttpTaskRequest
- (NSMutableDictionary *)params
{
    if (!_params) {
        _params = [[NSMutableDictionary alloc] init];
    }
    return _params;
}

- (NSMutableDictionary *)signParams
{
    if (!_signParams) {
        _signParams = [[NSMutableDictionary alloc] init];
    }
    return _signParams;
}

- (NSMutableDictionary *)headers
{
    if (!_headers) {
        _headers = [[NSMutableDictionary alloc] init];
    }
    return _headers;
}

- (NSMutableArray *)cookies
{
    if (!_cookies) {
        _cookies = [[NSMutableArray alloc] init];
    }
    return _cookies;
}
@end

/**
 * 请求响应
 */
@implementation HAHttpTaskResponse

@end

/**
 * HAHttpTask
 */
@interface HAHttpTask()
{
    NSMutableArray<id<HAHttpTaskFilter>> *_filters;
}

+ (NSInteger)getindex;

@end

@implementation HAHttpTask
@synthesize index = _index;

+ (NSInteger)getindex
{
    @synchronized(self)  {
        sHttpTaskindex ++;
    }
    
    return sHttpTaskindex;
}

+ (HAHttpTask*)task
{
    @synchronized(self)  {
        HAHttpTask* task = [[HAHttpTask alloc] init];
        return task;
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _index = [HAHttpTask getindex];
        self.request = [[HAHttpTaskRequest alloc] init];
        self.response = [[HAHttpTaskResponse alloc] init];
    }
    
    return self;
}

#pragma mark - public
- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[HAHttpTask class]]) {
        HAHttpTask* task = (HAHttpTask*)anObject;
        return self.index == task.index;
    }
    
    return NO;
}

- (void)addFilter:(id<HAHttpTaskFilter>)filter
{
    // 如果任务已经开始，就不能添加插件了
    if (self.status > 0) {
        assert(YES);
    }
    
    if (!_filters) {
        _filters = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    [_filters addObject:filter];
}

- (void)removeAllFilter
{
    [_filters removeAllObjects];
}

- (NSString*)getCacheUrl
{
    if (!self.cacheRequest) {
        return nil;
    }
    
    NSMutableString *query = [NSMutableString string];
    NSString* cacheUrl = self.request.url;
    if (self.request.params) {
        for (NSString *key in self.request.params.allKeys) {
            id value = [self.request.params valueForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                NSString* str = value;
                [query appendFormat:@"%@=%@&", [self urlEncode:key], [self urlEncode:str]];
            }
            else {
                if ([value respondsToSelector:@selector(stringValue)]) {
                    NSString* str = [value stringValue];
                    [query appendFormat:@"%@=%@&", [self urlEncode:key], [self urlEncode:str]];
                }
                else {
                    HttpLog_Condition(kHttpLogError, @"************************error************************\nerror - HTTP - GET: params(%@) can not convert to NSString", key);
                }
            }
        }
        
        if ([query length] > 0) {
            cacheUrl = [NSString stringWithFormat:@"%@?%@", self.request.url, [query substringToIndex:query.length - 1]];
        }
    }
    
    return cacheUrl;
}

- (void)notifyTaskStatusChanged:(HttpTaskStatus)status
{
    if (self.status == status) {
        return;
    }
    self.status = status;
    
    switch (self.status) {
        case HttpTaskStatusBuildParams: {
            for (id<HAHttpTaskFilter> filter in _filters) {
                if ([filter conformsToProtocol:@protocol(HAHttpTaskBuildParamsFilter)]) {
                    [(id<HAHttpTaskBuildParamsFilter>) filter onHAHttpTaskBuildParamsFilterExecute:self];
                }
            }
        }
            break;
        case HttpTaskStatusEnterQueue: {
            if (self.requestDelegate) {
                if ([self.requestDelegate respondsToSelector:@selector(onHttpTaskRequestEnterQueue:)]) {
                    [self.requestDelegate onHttpTaskRequestEnterQueue:self];
                }
            }
            
            for (id<HAHttpTaskFilter> filter in _filters) {
                if ([filter conformsToProtocol:@protocol(HAHttpTaskEnterQueueFilter)]) {
                    [(id<HAHttpTaskEnterQueueFilter>) filter onHAHttpTaskEnterQueueFilterExecute:self];
                }
            }
        }
            break;
        case HttpTaskStatusStarted: {
            if (self.requestDelegate) {
                if ([self.requestDelegate respondsToSelector:@selector(onHttpTaskRequestStarted:)]) {
                    [self.requestDelegate onHttpTaskRequestStarted:self];
                }
            }
            
            for (id<HAHttpTaskFilter> filter in _filters) {
                if ([filter conformsToProtocol:@protocol(HAHttpTaskStartedFilter)]) {
                    [(id<HAHttpTaskStartedFilter>) filter onHAHttpTaskStartedFilterExecute:self];
                }
            }
        }
            break;
        case HttpTaskStatusSucceeded: {
            if (self.requestDelegate) {
                if ([self.requestDelegate respondsToSelector:@selector(onHttpTaskRequestSucceeded:)]) {
                    [self.requestDelegate onHttpTaskRequestSucceeded:self];
                }
            }
            
            for (id<HAHttpTaskFilter> filter in _filters) {
                if ([filter conformsToProtocol:@protocol(HAHttpTaskSucceededFilter)]) {
                    [(id<HAHttpTaskSucceededFilter>) filter onHAHttpTaskSucceededFilterExecute:self];
                }
                else if ([filter conformsToProtocol:@protocol(HAHttpTaskCompletedFilter)]) {
                    [(id<HAHttpTaskCompletedFilter>) filter onHAHttpTaskCompletedFilterExecute:self];
                }
            }
        }
            break;
        case HttpTaskStatusFailed: {
            if (self.requestDelegate) {
                if ([self.requestDelegate respondsToSelector:@selector(onHttpTaskRequestFailed:)]) {
                    [self.requestDelegate onHttpTaskRequestFailed:self];
                }
            }
            
            for (id<HAHttpTaskFilter> filter in _filters) {
                if ([filter conformsToProtocol:@protocol(HAHttpTaskFailedFilter)]) {
                    [(id<HAHttpTaskFailedFilter>) filter onHAHttpTaskFailedFilterExecute:self];
                }
                else if ([filter conformsToProtocol:@protocol(HAHttpTaskCompletedFilter)]) {
                    [(id<HAHttpTaskCompletedFilter>) filter onHAHttpTaskCompletedFilterExecute:self];
                }
            }
        }
            break;
        case HttpTaskStatusCanceled: {
            if (self.requestDelegate) {
                if ([self.requestDelegate respondsToSelector:@selector(onHttpTaskRequestCanceled:)]) {
                    [self.requestDelegate onHttpTaskRequestCanceled:self];
                }
            }
            
            for (id<HAHttpTaskFilter> filter in _filters) {
                if ([filter conformsToProtocol:@protocol(HAHttpTaskCanceledFilter)]) {
                    [(id<HAHttpTaskCanceledFilter>) filter onHAHttpTaskCanceledFilterExecute:self];
                }
                else if ([filter conformsToProtocol:@protocol(HAHttpTaskCompletedFilter)]) {
                    [(id<HAHttpTaskCompletedFilter>) filter onHAHttpTaskCompletedFilterExecute:self];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - private
- (NSString*)urlEncode:(NSString*)text
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)text, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    return result;
}

@end
