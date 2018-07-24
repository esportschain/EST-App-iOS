//
//  HttpTaskCommonParamsFilter.m
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "HttpTaskCommonParamsFilter.h"
#import "HAHttpTask.h"
#import <AdSupport/AdSupport.h>

@implementation HttpTaskCommonParamsFilter
SYNTHESIZE_SINGLETON_FOR_CLASS(HttpTaskCommonParamsFilter);

- (void)onHAHttpTaskBuildParamsFilterExecute:(HAHttpTask*)task
{
//    NSDictionary* mainBundleInfo = [[NSBundle mainBundle] infoDictionary];
//    [task.request.params setValue:@"1" forKey:@"api"]; // use new api
//    [task.request.params setValue:@"ios" forKey:@"client"];
//    [task.request.params setValue:[mainBundleInfo objectForKey:(NSString*)kCFBundleVersionKey] forKey:@"version"];
//    [task.request.params setValue:[mainBundleInfo objectForKey:@"UMENG Channel"] forKey:@"channel"];
//    [task.request.params setValue:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"deviceid"];
//    if ([AccountManager sharedInstance].account.userId.integerValue > 0) {
//        [task.request.params setValue:[AccountManager sharedInstance].account.userId forKey:@"user_id"];
//    }
}

@end
