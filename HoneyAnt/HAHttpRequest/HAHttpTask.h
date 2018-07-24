//
//  HAHttpTask.h
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

@class HAHttpTask;

/**
 * http请求状态
 */
typedef enum{
    HttpTaskStatusBuildParams = (0x00000001 << 0),
    HttpTaskStatusEnterQueue =  (0x00000001 << 1),
    HttpTaskStatusStarted =     (0x00000001 << 2),
    HttpTaskStatusSucceeded =   (0x00000001 << 3),
    HttpTaskStatusFailed =      (0x00000001 << 4),
    HttpTaskStatusCanceled =    (0x00000001 << 5),
}HttpTaskStatus;

/**
 * http请求类型
 */
typedef enum {
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodOptions,
    HttpMethodHead,
    HttpMethodDelete,
    HttpMethodPut,
    HttpMethodTrace,
    HttpMethodGetCache
} HttpMethod;

/**
 * 网络任务请求过程监听器，如果设置此监听，请求完成后HAHttpTaskResponse的data里是没有数据的，数据要监听者自已处理，task.data中不包含请求回来的数据
 * 一般用于断点下载
 */
@protocol HAHttpTaskRequestDelegate <NSObject>

@required
- (void)onHttpTaskRequest:(HAHttpTask*)task didReceiveContentLength:(long long)contentLength;
- (void)onHttpTaskRequest:(HAHttpTask*)task didReceiveData:(NSData*)data;

@optional
- (void)onHttpTaskRequest:(HAHttpTask*)task didReceiveResponseHeaders:(NSDictionary *)responseHeaders;

- (void)onHttpTaskRequestEnterQueue:(HAHttpTask*)task;
- (void)onHttpTaskRequestStarted:(HAHttpTask*)task;
- (void)onHttpTaskRequestSucceeded:(HAHttpTask*)task;
- (void)onHttpTaskRequestFailed:(HAHttpTask*)task;
- (void)onHttpTaskRequestCanceled:(HAHttpTask*)task;


- (void)onHttpTaskRequest:(HAHttpTask*)task willRedirect:(NSURL*)newURL;
- (void)onHttpTaskRequestRedirected:(HAHttpTask*)task;

- (void)onHttpTaskRequestAuthenticationNeeded:(HAHttpTask*)task;
- (void)onHttpTaskRequestProxyAuthenticationNeeded:(HAHttpTask*)task;

@end

/**
 * 网络任务进度监听器
 */
@protocol HAHttpTaskProgressDelegate <NSObject>

@required
- (void)onHttpTaskProgress:(HAHttpTask*)task didSendBytes:(long long)bytes;
- (void)onHttpTaskProgress:(HAHttpTask*)task didReceiveBytes:(long long)bytes;

@optional
- (void)onHttpTaskProgress:(HAHttpTask*)task incrementUploadSizeBy:(long long)newLength;
- (void)onHttpTaskProgress:(HAHttpTask*)task incrementDownloadSizeBy:(long long)newLength;

@end

/**
 * form表单提交的数据，放到HAHttpTaskRequest的params里
 */
@interface HAFormPost : HAObject
@property(nonatomic, strong) NSString* fileName;     // pic.jpeg...
@property(nonatomic, strong) NSString* contentType;  // image/jpeg...
@end

/**
 * form表单提交的数据，放到HAHttpTaskRequest的params里
 */
@interface HAFormPostData : HAFormPost
@property(nonatomic, strong) NSData*   data;         // 数据
@end

/**
 * form表单提交的文件，放到HAHttpTaskRequest的params里
 */
@interface HAFormPostFile : HAFormPost
@property(nonatomic, strong) NSString* filePath;     // 文件路径
@end

/**
 * 请求参数
 */
@interface HAHttpTaskRequest : HAObject

@property(nonatomic, strong) NSString* url;
@property(nonatomic, assign) HttpMethod method;
@property(nonatomic, strong) NSMutableDictionary<NSString*, NSObject*> *params; // NSString或HAFormPost

// 签名参数与普通参数分开，主要是为了保持get url里不变的部份存放在params，这样可以根据url进行请求结果的缓存
@property(nonatomic, strong) NSMutableDictionary<NSString*, NSObject*> *signParams; // NSString或HAFormPost

@property(nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *headers;
@property(nonatomic, strong) NSMutableArray<NSString*> *cookies;
@property(nonatomic, strong) NSDictionary *credentials;

@property(nonatomic, assign) unsigned long long offset; // 分段请求偏移
@property(nonatomic, assign) unsigned long long length; // 分段请求长度

@end

/**
 * 请求响应
 */
@interface HAHttpTaskResponse : HAObject
@property(nonatomic, assign) int statusCode; // 200...
@property(nonatomic, strong) NSString *statusMessage;

@property(nonatomic, strong) NSDictionary *headers;
@property(nonatomic, strong) NSArray *cookies;

@property(nonatomic, assign) unsigned long long contentLength;
@property(nonatomic, assign) BOOL isCompressed;
@property(nonatomic, assign) NSStringEncoding encoding;
@property(nonatomic, strong) NSData* data;  // 请求结果
@property(nonatomic, strong) NSError* error;// 请求失败时的错误信息
@end

/**
 * 任务状态处理插件
 */
@protocol HAHttpTaskFilter <NSObject>
@end

@protocol HAHttpTaskBuildParamsFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskBuildParamsFilterExecute:(HAHttpTask*)task;
@end

@protocol HAHttpTaskEnterQueueFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskEnterQueueFilterExecute:(HAHttpTask*)task;
@end

@protocol HAHttpTaskStartedFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskStartedFilterExecute:(HAHttpTask*)task;
@end

@protocol HAHttpTaskSucceededFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task;
@end

@protocol HAHttpTaskFailedFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskFailedFilterExecute:(HAHttpTask*)task;
@end

@protocol HAHttpTaskCanceledFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskCanceledFilterExecute:(HAHttpTask*)task;
@end

// HttpTaskStatusSucceeded|HttpTaskStatusFailed|HttpTaskStatusCanceled
@protocol HAHttpTaskCompletedFilter <HAHttpTaskFilter>
- (void)onHAHttpTaskCompletedFilterExecute:(HAHttpTask*)task;
@end

/**
 * http任务
 */
@interface HAHttpTask : HAObject

// 自增序号
@property(nonatomic, assign, readonly) NSInteger index;

// 请求任务标识，一般用来标识每个接口，如shoplist
@property(nonatomic, strong) NSString* flag;

// 消除器，通常是一个UIViewController，当这个页面消失时，调用HAHttpTaskExecutor::cancelTaskByCanceler取消与这个页面相关的请求任务
@property(nonatomic, weak) id canceler;

// 关联用户数据，可以是任意类型数据
@property(nonatomic, strong) id userInfo;

// 是否缓存请求结果
@property(nonatomic, assign) BOOL cacheRequest;

// 请求参数
@property(nonatomic, strong) HAHttpTaskRequest* request;

// 响应数据
@property(nonatomic, strong) HAHttpTaskResponse* response;

// 当前任务状态
@property(nonatomic, assign) HttpTaskStatus status;

// 解析后的请求结果
@property(nonatomic, strong) id result;

// 超时时间，默认为0，默认取HAHttpTaskExecutor的超时时间；如果此处设置了值，则取此值为任务的超时时间
@property(nonatomic, assign) NSInteger timeout;

// 重试次数，默认为0，默认取HAHttpTaskExecutor的重试次数；如果此处设置了值，则取此值为任务的重试次数
@property(nonatomic, assign) NSInteger retryCount;

// 数据接收器，如果设置了此项，则请求完成后HAHttpTaskResponse的data里是没有数据的，数据要接收者自已处理
@property(nonatomic, weak) id<HAHttpTaskRequestDelegate> requestDelegate;

// 请求进度观察器
@property(nonatomic, weak) id<HAHttpTaskProgressDelegate> progressDelegate;

// 静态构造方法
+ (HAHttpTask*)task;

// 添加状态处理插件
- (void)addFilter:(id<HAHttpTaskFilter>)filter;
- (void)removeAllFilter;

// 获取缓存的url
- (NSString*)getCacheUrl;

// 通知任务状态改变
- (void)notifyTaskStatusChanged:(HttpTaskStatus)status;
@end
