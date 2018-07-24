//
//  NSString+EnDeCoding.h
//  SFSdk
//
//  Created by Song Xiaofeng on 13-7-26.
//  Copyright (c) 2013年 xiaofeng Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EnDeCoding)
/**
 *	@see stringByEscapingForURLArgument
 *
 *	@return	escapted string
 */
- (NSString*)urlEncode;

/**
 *	@see stringByUnescapingFromURLArgument
 *
 *	@return	unescapted string
 */
- (NSString*)urlDecode;

/**
 *	url argument escaping
 *
 *	@return	escapted string
 */
- (NSString*)stringByEscapingForURLArgument;

/**
 *	url argument unescaping
 *
 *	@return	unescapted string
 */
- (NSString*)stringByUnescapingFromURLArgument;

- (NSString*)base64Encode;
- (NSString*)base64Decode;

#pragma mark - Only Encoding
/**
 *  md5 encoding
 *
 *  @return lowercase encoding string
 */
- (NSString*)md5Encode;

/**
 *  md5 encoding
 *
 *  @return uppercase encoding string
 */
- (NSString*)MD5Encode;
@end
