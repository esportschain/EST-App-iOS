//
//  PushEntry.m
//  aimdev
//
//  Created by dongjianbo on 14-4-29.
//  Copyright (c) 2014年 tiantian. All rights reserved.
//

#import "PushEntry.h"
//#import "SMSDetailVC.h"
//#import "PostsDetailVC.h"

@implementation PushEntry
#pragma mark - ActionObject
- (BOOL) performWithUrl:(NSString*)actionUrl entryKey:(NSString*)entryKey queryDic:(NSMutableDictionary*)queryDic
{
    BOOL isPerform = NO;
    
//    if ([url rangeOfString:@"//sms"].location != NSNotFound) {
//        NSString* uid = [queryDic valueForKey:@"uid"];
//        
//        BaseVC* topVC = [TOP_NAVIGATOR getTopVC];
//        if ([topVC isMemberOfClass:[SMSDetailVC class]]) {
//            SMSDetailVC* vc = (SMSDetailVC*)topVC;
//            if ([vc.uid isEqualToString:uid]) {
//                [vc refresh];
//                isPerform = YES;
//            }
//        }
//        
//        if (!isPerform) {
//            SMSDetailVC* vc = [[SMSDetailVC alloc] init];
//            vc.uid = uid;
//            [TOP_NAVIGATOR pushVC:vc animated:YES];
//            isPerform = YES;
//        }
//    }
//    else if ([url rangeOfString:@"//sys"].location != NSNotFound) {
//        
//    }
//    else if ([url rangeOfString:@"//posts"].location != NSNotFound) {
//        NSString* fid = [queryDic valueForKey:@"fid"];
//        NSString* tid = [queryDic valueForKey:@"tid"];
//        
//        BaseVC* topVC = [TOP_NAVIGATOR getTopVC];
//        if ([topVC isMemberOfClass:[PostsDetailVC class]]) {
//            PostsDetailVC* vc = (PostsDetailVC*)topVC;
//            if ([vc.fid isEqualToString:fid] && [vc.tid isEqualToString:tid]) {
//                [vc refresh];
//                isPerform = YES;
//            }
//        }
//        
//        if (!isPerform) {
//            PostsDetailVC* vc = [[PostsDetailVC alloc] init];
//            vc.fid = fid;
//            vc.tid = tid;
//            [TOP_NAVIGATOR pushVC:vc animated:YES];
//            isPerform = YES;
//        }
//    }
//    else if ([url rangeOfString:@"//reply"].location != NSNotFound) {
//        NSString* fid = [queryDic valueForKey:@"fid"];
//        NSString* tid = [queryDic valueForKey:@"tid"];
//        
//        BaseVC* topVC = [TOP_NAVIGATOR getTopVC];
//        if ([topVC isMemberOfClass:[PostsDetailVC class]]) {
//            PostsDetailVC* vc = (PostsDetailVC*)topVC;
//            if ([vc.fid isEqualToString:fid] && [vc.tid isEqualToString:tid]) {
//                [vc refresh];
//                isPerform = YES;
//            }
//        }
//        
//        if (!isPerform) {
//            PostsDetailVC* vc = [[PostsDetailVC alloc] init];
//            vc.fid = fid;
//            vc.tid = tid;
//            [TOP_NAVIGATOR pushVC:vc animated:YES];
//            isPerform = YES;
//        }
//    }
    
    return isPerform;
}
@end
