//
//  HttpTaskCacheFilter.m
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "HttpTaskCacheFilter.h"
#import "HAStringUtil.h"

@implementation HttpTaskCacheFilter
SYNTHESIZE_SINGLETON_FOR_CLASS(HttpTaskCacheFilter);

#pragma mark - HAHttpTaskSucceededFilter
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    if (task.cacheRequest) {
        if (task.response.data) {
            HttpResult* result = (HttpResult*)task.result;
            // 只在请求成功的情况下缓存数据
            if (result.code == HTTP_RESULT_SUCCESS) {
                NSString* cacheFilePath = [NSString stringWithFormat:@"%@/%@", kPathUrlCache, [HAStringUtil md5:[task getCacheUrl]]];
                [task.response.data writeToFile:cacheFilePath atomically:YES];
            }
        }
    }
}

@end
