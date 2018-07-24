//
//  HAURLUtil.m
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

#import "HAURLUtil.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation HAURLUtil

+ (NSString*)urlDecode:(NSString*)text
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)text, CFSTR(""), kCFStringEncodingUTF8);
    return result;
}

+ (NSString*)urlEncode:(NSString*)text
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)text, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    return result;
}

/*
 * used to decompose the url string and store the keys and values to dictionary.
 *    eg.
 *        @"key1=value1&key2=value2&key=value3"
 *  will be stored to dictionary as:
 *        key1<=value1,  key2<=value2, key3<=value3
 */
+ (NSMutableDictionary*)decomposeUrl:(NSString*)query
{
    NSArray *array = [query componentsSeparatedByString:@"&"];
    if ([array count] > 0) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        for(NSString *str in array){
            NSArray *keyandvalue = [str componentsSeparatedByString:@"="];
            if([keyandvalue count] == 2)
                [dic setValue:[HAURLUtil urlDecode:[keyandvalue objectAtIndex:1]] forKey:[keyandvalue objectAtIndex:0]];
        }
        
        if ([[dic allKeys] count] >0) {
            return dic;
        }
        
        return nil;
    }
    
    return nil;
}

+ (NSString*)composeUrl:(NSMutableDictionary*)queryDic
{
    if (queryDic) {
        NSMutableString *query = [NSMutableString string];
        for (NSString *key in queryDic.allKeys) {
            id value = [queryDic valueForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                NSString* str = value;
                [query appendFormat:@"%@=%@&", [HAURLUtil urlEncode:key], [HAURLUtil urlEncode:str]];
            }
            else if ([value respondsToSelector:@selector(stringValue)]) {
                NSString* str = [value stringValue];
                [query appendFormat:@"%@=%@&", [HAURLUtil urlEncode:key], [HAURLUtil urlEncode:str]];
            }
        }
        
        if ([query length] > 0) {
            return query;
        }
        
        return nil;
    }
    
    return nil;
}


@end
