//
//  Html5Entry.m
//  aimdev
//
//  Created by dongjianbo on 14-2-27.
//  Copyright (c) 2014年 aimdev. All rights reserved.
//

#import "Html5Entry.h"
//#import "FriendProfileVC.h"

typedef enum {
    ENTRY_UNKNOWN,
    ENTRY_FRIENDPROFILE = 1,
    ENTRY_REPLY
} ENTRY_TYPE;

@implementation Html5Entry

#pragma mark - ActionObject
- (BOOL) performWithUrl:(NSString*)actionUrl entryKey:(NSString*)entryKey queryDic:(NSMutableDictionary*)queryDic
{
    BOOL isPerform = NO;
//    if ([host host isEqualToString:@"/login.php"].location != NSNotFound) {
//        [Project_AppDelegate showLoginVC];
//        return YES;
//    }
//    
//    if ([url rangeOfString:@"/home.php"].location != NSNotFound) {
//        NSString* mode = [queryDic valueForKey:@"mod"];
//        NSString* uid = [queryDic valueForKey:@"uid"];
//        NSString* uname = [queryDic valueForKey:@"uname"];
//        if ([mode isEqualToString:@"space"] && [uid length] > 0 && [uname length] > 0) {
//            FriendProfileVC* vc = [[FriendProfileVC alloc] init];
//            vc.uid = uid;
//            vc.uname = uname;
//            [Project_HomeVC pushViewController:vc animated:YES];
//            return YES;
//        }
//    }
//    
    return isPerform;
}

@end
