//
//  HttpTaskFailedFilter.m
//  beacon
//
//  Created by dongjianbo on 16/8/29.
//  Copyright © 2016年 mafengwo. All rights reserved.
//

#import "HttpTaskFailedFilter.h"

@implementation HttpTaskFailedFilter
SYNTHESIZE_SINGLETON_FOR_CLASS(HttpTaskFailedFilter);

#pragma mark - HAHttpTaskFailedFilter
- (void)onHAHttpTaskFailedFilterExecute:(HAHttpTask*)task
{
    NSLog(@"HttpRequestFailed: status-%d url-%@ error-%@", task.status, task.request.url, task.response.error.domain);
}
@end
