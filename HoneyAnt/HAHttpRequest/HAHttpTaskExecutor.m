//
//  HAHttpTaskExecutor.m
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

#import "HAHttpTaskExecutor.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

#define kRequestUserInfoTask   @"task"
#define kRequestUserInfoTime   @"time"

// HAHttpTaskCompletedBlockFilter
@implementation HAHttpTaskCompletedBlockFilter
-(void) onHAHttpTaskCompletedFilterExecute:(HAHttpTask*)task { if(self.block) {self.block(task);} }
@end

// HAHttpTaskExecutor
@interface HAHttpTaskExecutor()<ASIHTTPRequestDelegate, ASIProgressDelegate>
@property(nonatomic, strong)ASINetworkQueue* networkQueue;
@property(nonatomic, assign)NSInteger timeOut;
@property(nonatomic, assign)NSInteger retryCount;
@end

@implementation HAHttpTaskExecutor

- (id)init
{
    self = [super init];
    if(self) {
        self.networkQueue = [[ASINetworkQueue alloc] init];
        [self.networkQueue setDelegate:self];
        [self.networkQueue setRequestDidStartSelector:@selector(onQueueRequestStarted:)];
        [self.networkQueue setRequestDidFinishSelector:@selector(onQueueRequestFinished:)];
        [self.networkQueue setRequestDidFailSelector:@selector(onQueueRequestFailed:)];
        [self.networkQueue setMaxConcurrentOperationCount:4];
        [self.networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [self.networkQueue setShowAccurateProgress:YES];
        [self.networkQueue go];
        
        self.timeOut = 10;
        self.retryCount = 1;
    }
    
    return self;
}

#pragma mark - public
- (void)setMaxOperationCount:(NSInteger)count
{
    if (count > 0) {
        [self.networkQueue setMaxConcurrentOperationCount:count];
    }
}

- (void)setTimeout:(NSInteger)timeout
{
    if (timeout > 0) {
        _timeOut = timeout;
    }
}

// 设置重试次数
- (void)setRetryCount:(NSInteger)retryCount
{
    if (retryCount > 0) {
        _retryCount = retryCount;
    }
}

- (void)execute:(HAHttpTask*)task complete:(HAHttpTaskCompletedBlock)completeBlock
{
    if (completeBlock) {
        HAHttpTaskCompletedBlockFilter* completedBlockFilter = [[HAHttpTaskCompletedBlockFilter alloc] init];
        completedBlockFilter.block = completeBlock;
        [task addFilter:completedBlockFilter];
    }
    
    // check need add to queue
    BOOL needAdd = YES;
    NSArray* allRequests = [self.networkQueue operations];
    for (ASIHTTPRequest* request in allRequests) {
        HAHttpTask* combineRequest = [request.userInfo objectForKey:kRequestUserInfoTask];
        if ([task isEqual:combineRequest]) {
            needAdd = NO;
            break;
        }
    }
    
    // add task to queue
    if(needAdd) {
        // 通知监听器构建请求参数
        [task notifyTaskStatusChanged:HttpTaskStatusBuildParams];
        
        ASIHTTPRequest* httpRequest = nil;
        switch (task.request.method) {
            case HttpMethodPost:{
                httpRequest = [self createPostRequest:task];
            }
                break;
            case HttpMethodOptions:{
                httpRequest = [self createPostRequest:task];
                [httpRequest setRequestMethod:@"OPTIONS"];
            }
                break;
            case HttpMethodHead:{
                httpRequest = [self createPostRequest:task];
                [httpRequest setRequestMethod:@"HAED"];
            }
                break;
            case HttpMethodDelete:{
                httpRequest = [self createPostRequest:task];
                [httpRequest setRequestMethod:@"DELETE"];
            }
                break;
            case HttpMethodPut:{
                httpRequest = [self createPostRequest:task];
                [httpRequest setRequestMethod:@"PUT"];
            }
                break;
            case HttpMethodTrace:{
                httpRequest = [self createPostRequest:task];
                [httpRequest setRequestMethod:@"TRACE"];
            }
                break;
            default:{
                httpRequest =  [self createGetRequest:task];
            }
                break;
        }
        
        // 超时时间
        if (task.timeout > 0) {
            [httpRequest setTimeOutSeconds:task.timeout];
        }
        else {
            [httpRequest setTimeOutSeconds:self.timeOut];
        }
        
        // 重试次数
        if (task.retryCount > 0) {
            [httpRequest setNumberOfTimesToRetryOnTimeout:task.retryCount];
        }
        else {
            [httpRequest setNumberOfTimesToRetryOnTimeout:self.retryCount];
        }
        
        // progress delegate
        if(task.progressDelegate) {
            httpRequest.showAccurateProgress = YES;
            httpRequest.downloadProgressDelegate = self;
            httpRequest.uploadProgressDelegate = self;
        }
        else {
            httpRequest.showAccurateProgress = NO;
        }
        
        // request delegate
        if (task.requestDelegate) {
            httpRequest.delegate = self;
        }
        
        // offset header
        if (task.request.offset > 0 || task.request.length > 0) {
            NSString* offset = task.request.offset > 0 ? [NSString stringWithFormat:@"%lld", task.request.offset] : @"";
            NSString* length = task.request.length > 0 ? [NSString stringWithFormat:@"%lld", task.request.offset + task.request.length - 1] : @"";
            NSString *value = [NSString stringWithFormat:@"bytes=%@-%@", offset, length];
            [httpRequest addRequestHeader:@"Range" value:value];
        }
        
        // headers
        if (task.request.headers) {
            for (NSString *key in task.request.headers.allKeys) {
                id value = [task.request.headers valueForKey:key];
                if ([value isKindOfClass:[NSString class]]) {
                    [httpRequest addRequestHeader:key value:(NSString*)value];
                }
                else {
                    HttpLog_Condition(kHttpLogError, @"************************error************************\nerror - HTTP - Header: value(%@) is not kind of NSString", key);
                }
            }
        }
        
        // cookies
        if (task.request.cookies) {
            [httpRequest setRequestCookies:task.request.cookies];
        }
        
        // credentials
        if (task.request.credentials) {
            [httpRequest setRequestCredentials:task.request.credentials];
        }
        
        // config
        [httpRequest setShouldAttemptPersistentConnection:NO];
        
        // request
        [self.networkQueue addOperation:httpRequest];
        
        // 通知监听器，任务已进入队列
        [task notifyTaskStatusChanged:HttpTaskStatusEnterQueue];
    }
    else { // 重复的请求，不做处理
        HttpLog_Condition(kHttpLogRequest, @"************************request************************\nrequest - HTTP - Repeat request");
    }
}

- (void)cancelTaskByIndex:(NSInteger)index
{
    NSArray* allRequests = [self.networkQueue operations];
    for (ASIHTTPRequest* request in allRequests) {
        HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
        if (task.index == index) {
            [self cancelTask:task request:request];
        }
    }
}

- (void)cancelTaskByFlag:(NSString*)flag
{
    NSArray* allRequests = [self.networkQueue operations];
    for (ASIHTTPRequest* request in allRequests) {
        HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
        if ([task.flag isEqualToString:flag]) {
            [self cancelTask:task request:request];
        }
    }
}

- (void)cancelTaskByCanceler:(id)cancler
{
    NSArray* allRequests = [self.networkQueue operations];
    for (ASIHTTPRequest* request in allRequests) {
        HAHttpTask* task = [request.userInfo objectForKey:kRequestUserInfoTask];
        if ([cancler isEqual:task.canceler]) {
            [self cancelTask:task request:request];
        }
    }
}

- (void)cancelAllTask
{
    NSArray* allRequests = [self.networkQueue operations];
    for (ASIHTTPRequest* request in allRequests) {
        HAHttpTask* task = [request.userInfo objectForKey:kRequestUserInfoTask];
        [self cancelTask:task request:request];
    }
}

#pragma mark - private
- (NSString*)urlEncode:(NSString*)text
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)text, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    return result;
}

- (ASIHTTPRequest *)createGetRequest:(HAHttpTask*)task
{
    NSURL *url = [NSURL URLWithString:task.request.url];
    
    // 合并参数
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:task.request.params];
    [params addEntriesFromDictionary:task.request.signParams];
    
    if (params) {
        NSMutableString *query = [NSMutableString string];
        for (NSString *key in params.allKeys) {
            id value = [params valueForKey:key];
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
                    HttpLog_Condition(kHttpLogError, @"************************error************************\nerror - HTTP - GET: value(%@) can not convert to NSString", key);
                }
            }
        }
        
        if (query.length > 0) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", task.request.url, [query substringToIndex:query.length - 1]]];
        }
    }
    
    HttpLog_Condition(kHttpLogRequest, @"HTTP************************\r\nURL:%@", url);
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:task, kRequestUserInfoTask, [NSNumber numberWithLong:time(nil)], kRequestUserInfoTime, nil];
    
    return request;
}

- (ASIHTTPRequest *)createPostRequest:(HAHttpTask*)task
{
    NSURL *url = [NSURL URLWithString:task.request.url];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:task, kRequestUserInfoTask, [NSNumber numberWithLong:time(nil)], kRequestUserInfoTime, nil];
    
    // 预设为urlencode post format
    request.postFormat = ASIURLEncodedPostFormat;
    
    // 合并参数
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:task.request.params];
    [params addEntriesFromDictionary:task.request.signParams];
    
    if (params) {
        for (NSString *key in params.allKeys) {
            id value = [params valueForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                NSString* str = value;
                [request setPostValue:str forKey:key];
            }
            else if ([value respondsToSelector:@selector(stringValue)]) {
                NSString* str = [value stringValue];
                [request addPostValue:str forKey:key];
            }
            else if ([value isKindOfClass:[HAFormPostData class]]) {
                HAFormPostData* dataParam = value;
                [request setData:dataParam.data withFileName:dataParam.fileName andContentType:dataParam.contentType forKey:key];
                request.postFormat = ASIMultipartFormDataPostFormat;
            }
            else if ([value isKindOfClass:[HAFormPostFile class]]) {
                HAFormPostFile* fileParam = value;
                [request setFile:fileParam.filePath withFileName:fileParam.fileName andContentType:fileParam.contentType forKey:key];
                request.postFormat = ASIMultipartFormDataPostFormat;
            }
            else {
                HttpLog_Condition(kHttpLogError, @"************************error************************\nerror - HTTP - POST: value(%@) must be convert to NSString or HAFormPostData or HAFormPostFile", key);
            }
        }
    }
    
    HttpLog_Condition(kHttpLogRequest, @"HTTP************************\r\nURL:%@\r\nParams:%@", url, params);
    
    [request buildPostBody];
    
    return request;
}

- (void)processTaskResponse:(HAHttpTask*)task request:(ASIHTTPRequest*)request
{
    task.response.statusCode = request.responseStatusCode;
    task.response.statusMessage = request.responseStatusMessage;
    task.response.contentLength = request.contentLength;
    task.response.isCompressed = request.isResponseCompressed;
    task.response.encoding = request.responseEncoding;
    task.response.headers = request.responseHeaders;
    task.response.cookies = request.responseCookies;
    task.response.data = request.responseData;
    task.response.error = request.error;
}

- (void) cancelTask:(HAHttpTask*)task request:(ASIHTTPRequest*)request
{
    [request clearDelegatesAndCancel];
    [task notifyTaskStatusChanged:HttpTaskStatusCanceled];
    
    task.canceler = nil;
    task.requestDelegate = nil;
    task.progressDelegate = nil;
    [task removeAllFilter];
}

#pragma mark - queue selector
- (void)onQueueRequestStarted:(ASIHTTPRequest *)request
{
    HAHttpTask* task = [request.userInfo objectForKey:kRequestUserInfoTask];
    [task notifyTaskStatusChanged:HttpTaskStatusStarted];
}

- (void)onQueueRequestFinished:(ASIHTTPRequest *)request
{
    HttpLog_Condition(kHttpLogResponse, @"HTTP************************\r\n requestSucceeded:%@", [request responseString]);
    
    HAHttpTask* task = [request.userInfo objectForKey:kRequestUserInfoTask];
    [self processTaskResponse:task request:request];
    if (task.response.statusCode == 200) {
        [task notifyTaskStatusChanged:HttpTaskStatusSucceeded];
    }
    else {
        if (!task.response.error) {
            task.response.error = [NSError errorWithDomain:task.response.statusMessage code:task.response.statusCode userInfo:nil];
        }
        [task notifyTaskStatusChanged:HttpTaskStatusFailed];
    }
}

- (void)onQueueRequestFailed:(ASIHTTPRequest *)request
{
    HttpLog_Condition(kHttpLogError, @"************************error************************\r\nrequestFailed:\r\ncode:%ld\r\ndomain:%@\r\nuserinfo:%@", (long)[[request error] code], [[request error] domain], [[request error] userInfo]);
    
    HAHttpTask* task = [request.userInfo objectForKey:kRequestUserInfoTask];
    [self processTaskResponse:task request:request];
    [task notifyTaskStatusChanged:HttpTaskStatusFailed];
}

#pragma mark - ASIHTTPRequestDelegate
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.requestDelegate) {
        NSString *lenString = [responseHeaders valueForKey:@"Content-Length"];
        [task.requestDelegate onHttpTaskRequest:task didReceiveContentLength:[lenString longLongValue]];
        
        if ([task.requestDelegate respondsToSelector:@selector(onHttpTaskRequest:didReceiveResponseHeaders:)]) {
            [task.requestDelegate onHttpTaskRequest:task didReceiveResponseHeaders:responseHeaders];
        }
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.requestDelegate) {
        [task.requestDelegate onHttpTaskRequest:task didReceiveData:data];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    [task notifyTaskStatusChanged:HttpTaskStatusStarted];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    
    [self processTaskResponse:task request:request];
    if (task.response.statusCode == 200) {
        [task notifyTaskStatusChanged:HttpTaskStatusSucceeded];
    }
    else {
        if (!task.response.error) {
            task.response.error = [NSError errorWithDomain:task.response.statusMessage code:task.response.statusCode userInfo:nil];
        }
        [task notifyTaskStatusChanged:HttpTaskStatusFailed];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    
    [self processTaskResponse:task request:request];
    [task notifyTaskStatusChanged:HttpTaskStatusFailed];
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.requestDelegate) {
        if ([task.requestDelegate respondsToSelector:@selector(onHttpTaskRequest:willRedirect:)]) {
            [task.requestDelegate onHttpTaskRequest:task willRedirect:newURL];
        }
    }
}

- (void)requestRedirected:(ASIHTTPRequest *)request
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.requestDelegate) {
        if ([task.requestDelegate respondsToSelector:@selector(onHttpTaskRequestRedirected:)]) {
            [task.requestDelegate onHttpTaskRequestRedirected:task];
        }
    }
}

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.requestDelegate) {
        if ([task.requestDelegate respondsToSelector:@selector(onHttpTaskRequestAuthenticationNeeded:)]) {
            [task.requestDelegate onHttpTaskRequestAuthenticationNeeded:task];
        }
    }
}

- (void)proxyAuthenticationNeededForRequest:(ASIHTTPRequest *)request
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.requestDelegate) {
        if ([task.requestDelegate respondsToSelector:@selector(onHttpTaskRequestProxyAuthenticationNeeded:)]) {
            [task.requestDelegate onHttpTaskRequestProxyAuthenticationNeeded:task];
        }
    }
}

#pragma mark - ASIProgressDelegate
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.progressDelegate) {
        [task.progressDelegate onHttpTaskProgress:task didSendBytes:bytes];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.progressDelegate) {
        [task.progressDelegate onHttpTaskProgress:task didReceiveBytes:bytes];
    }
}

- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.progressDelegate) {
        if ([task.progressDelegate respondsToSelector:@selector(onHttpTaskProgress:incrementUploadSizeBy:)]) {
            [task.progressDelegate onHttpTaskProgress:task incrementUploadSizeBy:newLength];
        }
    }
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    HAHttpTask* task = (HAHttpTask*)[request.userInfo objectForKey:kRequestUserInfoTask];
    if (task.progressDelegate) {
        if ([task.progressDelegate respondsToSelector:@selector(onHttpTaskProgress:incrementDownloadSizeBy:)]) {
            [task.progressDelegate onHttpTaskProgress:task incrementDownloadSizeBy:newLength];
        }
    }
}

@end
