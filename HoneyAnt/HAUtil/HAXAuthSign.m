//
//  HAXAuthSign.m
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

#import "HAXAuthSign.h"
#import <CommonCrypto/CommonHMAC.h>
#include "Base64Transcoder.h"
#import "HAStringUtil.h"
#import "HAURLUtil.h"
#import <AdSupport/AdSupport.h>

@interface HAXAuthSign()
+ (NSString *)signatureBase64Encode:(NSString *)text withSecret:(NSString *)secret;
+ (NSString *)base64Encode:(unsigned char*)p withLength:(int)length;
@end

@implementation HAXAuthSign

+ (NSMutableDictionary*)generateURLParams:(NSString*)httpMethod requestURL:(NSString*)requestURL params:(NSMutableDictionary*)params consumerKey:(NSString*)consumerKey consumerKeySecret:(NSString*)consumerKeySecret accessToken:(NSString*)accessToken tokenSecret:(NSString*)tokenSecret
{
    NSMutableDictionary* signParams = [NSMutableDictionary dictionaryWithCapacity:16];
    
    int timeStamp = (int)[[NSDate date] timeIntervalSince1970];
    int random = rand();
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *nonce = [NSString stringWithFormat:@"%d,%d,%@", timeStamp, random, adId];
    
    if (accessToken && [accessToken length] > 0) {
        [signParams setValue:accessToken forKey:@"oauth_token"];
    }
    [signParams setValue:consumerKey forKey:@"oauth_consumer_key"];
    [signParams setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    [signParams setValue:[NSString stringWithFormat:@"%d", timeStamp] forKey:@"oauth_timestamp"];
    [signParams setValue:[HAStringUtil md5:[NSString stringWithFormat:@"%@", nonce]] forKey:@"oauth_nonce"];
    [signParams setValue:@"1.0" forKey:@"oauth_version"];
    
    // 合并参数
    NSMutableDictionary* baseParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [baseParams addEntriesFromDictionary:signParams];
    
    NSMutableString *sortStr = [NSMutableString string];
    NSArray * allKeys = [[baseParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for(NSString *key in allKeys) {
        NSObject* object = [baseParams valueForKey:key];
        NSString* value = nil;
        if ([object isKindOfClass:[NSString class]]) {
            value = (NSString*)object;
        }
        else if ([object respondsToSelector:@selector(stringValue)]) {
            value = [object performSelector:@selector(stringValue)];
        }
        
        if (value) {
            if ([sortStr length] > 0) {
                [sortStr appendString:@"&"];
            }
            
            [sortStr appendFormat:@"%@=%@", [HAURLUtil urlEncode:key], [HAURLUtil urlEncode:value]];
        }
    }
    
    NSMutableString *baseString = [NSMutableString string];
    [baseString appendString:httpMethod];
    [baseString appendString:@"&"];
    [baseString appendString:[HAURLUtil urlEncode:requestURL.lowercaseString]];
    [baseString appendString:@"&"];
    [baseString appendString:[HAURLUtil urlEncode:sortStr]];
    
    if (!tokenSecret) {
        tokenSecret = @"";
    }
    NSString* secret = [NSString stringWithFormat:@"%@&%@", [HAURLUtil urlEncode:consumerKeySecret], [HAURLUtil urlEncode:tokenSecret]];
    
    NSString* signature = [HAXAuthSign signatureBase64Encode:baseString withSecret:secret];
    [signParams setValue:signature forKey:@"oauth_signature"];
    
    return signParams;
}

+ (NSString *)signatureBase64Encode:(NSString *)text withSecret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    //Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    return base64EncodedResult;
}

+ (NSString *)base64Encode:(unsigned char*)p withLength:(int)length{
    
    char *base64Result;
    size_t theResultLength = length*4/3+5;
    base64Result = (char *)malloc(theResultLength);
    
    Base64EncodeData(p, length, base64Result, &theResultLength);
    base64Result[theResultLength]='\0';
    
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    free(base64Result);
    
    return base64EncodedResult;
}

@end
