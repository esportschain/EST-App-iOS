//
//  NSString+UUID.m
//  SFSdk
//
//  Created by xiaofeng on 14-4-19.
//  Copyright (c) 2014年 xiaofeng. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)
+ (NSString*)uuidStr;
{
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *guid = (__bridge NSString *)newUniqueIDString;
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    return([guid lowercaseString]);
}
@end
