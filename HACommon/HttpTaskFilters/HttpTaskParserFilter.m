//
//  HttpTaskParserFilter.m
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "HttpTaskParserFilter.h"
#import "HADataWrapper.h"
#import "HttpResult.h"

@implementation HttpTaskParserFilter
SYNTHESIZE_SINGLETON_FOR_CLASS(HttpTaskParserFilter);

#pragma mark - HAHttpTaskSucceededFilter
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    if (task.response.data) {
        HttpResult* result = [[HttpResult alloc] init];
        HADataWrapper* responseWrapper = [HADataWrapper dataWrapperWithJsonData:task.response.data];
        [result parseDataWrapper:responseWrapper];
        task.result = result;
        
        NSLog(@"responseString: %@",responseWrapper);
    } else{
        task.result = [[HttpResult alloc] init];
    }
}

@end
