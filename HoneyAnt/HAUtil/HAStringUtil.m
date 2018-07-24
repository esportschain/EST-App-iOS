//
//  HAStringUtil.m
//  HoneyAnt
//
//  Created by dongjianbo on 15-2-12.
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

#import "HAStringUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "regex.h"

@implementation HAStringUtil

+ (NSString *)sha1:(NSString *)text
{
	// 分配hash结果空间
	uint8_t *hashBytes = malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
	if(hashBytes) {
		memset(hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
        
		// 计算hash值
		NSData *srcData = [text dataUsingEncoding:NSUTF8StringEncoding];
		CC_SHA1((void *)[srcData bytes], (CC_LONG)[srcData length], hashBytes);
        
		// 组建String
		NSMutableString* destString = [[NSMutableString alloc] initWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
		for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
			[destString appendFormat:@"%02X", hashBytes[i]];
		}
		
		// 释放空间
		free(hashBytes);
		
		return destString;
	}
	
	return nil;
}

+ (NSString *)md5:(NSString *)text
{
    const char *cStr = [text cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)(strlen(cStr)), result);
    return [[NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

/**
 * sourceStr: 源字符串
 * pattern: 替换前的字符串/正则表达式
 * template: 替换后的字符串
 */
+ (NSMutableString*)replaceMatchesInString:(NSMutableString*)sourceStr pattern:(NSString*)pattern withTemplate:(NSString*)tmeplateStr
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    [regex replaceMatchesInString:sourceStr options:0 range:NSMakeRange(0, [sourceStr length]) withTemplate:tmeplateStr];
    
    return sourceStr;
}

+ (BOOL)RegExpMatch:(NSString *)text withPattern:(NSString*)pattern{
    
    regex_t reg;
    
    int status = regcomp(&reg, [pattern UTF8String], REG_EXTENDED);
    if(status) {
        return NO;
    }
    
    status = regexec(&reg, [text UTF8String], 0, nil, 0);
    regfree( &reg );
    
    if(status == REG_NOMATCH) {
        return NO;
    }
    else if(status) {
        return NO;
    }
    
    return YES;
}

+ (NSInteger)hex2Int:(NSString *)text
{
    NSInteger result = 0;
    NSInteger count = [text length];
    for (NSInteger i = 0; i < count; i++) {
        unichar c = [text characterAtIndex:i];
        NSInteger tmp = 0;
        if(c>='0' && c <= '9')
            tmp = c - '0';
        if(c >= 'a' && c <= 'f')
            tmp = c - 'a' + 10;
        if(c >= 'A' && c <= 'F')
            tmp = c - 'A' + 10;
        result = result * 16 + tmp;
    }
    
    return result;
}

+ (BOOL)isPhoneNumberValidate:(NSString *)phone
{
    NSString *mobile = @"^1\\d{10}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobile];
    return  [regextestmobile evaluateWithObject:phone];
}

+ (BOOL)isEmptyString:(NSString*)string;
{
    if (string && [string isKindOfClass:[NSString class] ] && [string length] > 0)
    {
        return NO;
    }
    return YES;
}

@end

