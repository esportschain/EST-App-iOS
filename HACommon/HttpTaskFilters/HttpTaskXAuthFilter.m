//
//  HttpTaskXAuthFilter.m
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "HttpTaskXAuthFilter.h"
#import "HAHttpTask.h"
#import "HAXAuthSign.h"

@implementation HttpTaskXAuthFilter
SYNTHESIZE_SINGLETON_FOR_CLASS(HttpTaskXAuthFilter);

#pragma mark - HAHttpTaskBuildParamsFilter

- (void)onHAHttpTaskBuildParamsFilterExecute:(HAHttpTask*)task
{
    NSLog(@"url: %@",task.request.url);
    NSLog(@"url-params: %@",task.request.params);
}


@end
