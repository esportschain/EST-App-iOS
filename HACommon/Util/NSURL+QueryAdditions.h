//
//  NSURL+QueryAdditions.h
//  SFSdk
//
//  Created by Song Xiaofeng on 13-8-7.
//  Copyright (c) 2013年 xiaofeng Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryAdditions)

/**
 * &key1=value1&key2=value2
 * @return dictionary里的value经过url decode
 */
+ (NSDictionary*)decodedParametersForQuery:(NSString*)queryStr;

/**
 * &key1=value1&key2=value2
 * @return dictionary里的value __未__ 经过url decode
 */
+ (NSDictionary*)rawDicParametersForQueryParameters:(NSString*)queryStr;

/**
 * @param dictionary里的value经过url decode
 */
+ (NSString*)queryStringForDicParameters:(NSDictionary*)dic;
/**
 * @param dictionary里的value __未__ 经过url decode
 */
+ (NSString*)queryStringForRawDicParameters:(NSDictionary*)rawDic;

@end
