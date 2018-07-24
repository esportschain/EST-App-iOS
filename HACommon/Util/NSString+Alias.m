//
//  NSString+Alias.m
//  Jiji
//
//  Created by xiaofeng on 14-4-21.
//  Copyright (c) 2014年 xiaofeng. All rights reserved.
//

#import "NSString+Alias.h"

@implementation NSString (Alias)
- (NSString*)trim;
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
