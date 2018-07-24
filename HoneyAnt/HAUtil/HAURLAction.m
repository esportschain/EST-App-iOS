//
//  HAURLAction.m
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

#import "HAURLAction.h"
#import "HAURLUtil.h"

/**
 * HAURLActionCenter
 */
@implementation HAURLActionCenter
SYNTHESIZE_SINGLETON_FOR_CLASS(HAURLActionCenter);

- (id)init
{
    self = [super init];
    if (self) {
        self.actionProtocolArray = [NSMutableArray arrayWithCapacity:2];
    }
    
    return self;
}

- (NSMutableArray*)actionProtocolArray
{
    if (!_actionProtocolArray) {
        _actionProtocolArray = [[NSMutableArray alloc] init];
    }
    
    return _actionProtocolArray;
}

- (BOOL) performWithUrl:(NSString*)actionUrl
{
    BOOL success = NO;
    if ([self.actionProtocolArray count] > 0) {
        for (HAURLActionCenterProtocol* actionProtocol in self.actionProtocolArray) {
            success = [actionProtocol performWithUrl:actionUrl];
            if (success) {
                break;
            }
        }
    }
    
    return success;
}

@end

/**
 * HAURLActionCenterProtocol
 */
@implementation HAURLActionCenterProtocol

- (id)init
{
    self = [super init];
    if (self) {
        self.entryMap = [NSMutableDictionary dictionaryWithCapacity:16];
    }
    
    return self;
}

- (NSMutableDictionary*)entryMap
{
    if (!_entryMap) {
        _entryMap = [[NSMutableDictionary alloc] init];
    }
    
    return _entryMap;
}

- (BOOL) performWithUrl:(NSString*)actionUrl
{
    // url协议为空
    if (!self.protocol || [self.protocol length] <= 0) {
        return NO;
    }
    
    // action 为空
    if (!actionUrl || [actionUrl length] <= 0) {
        return NO;
    }
    
    // url协议不匹配
    NSRange range = [actionUrl rangeOfString:self.protocol];
    if (range.location == NSNotFound) {
        return NO;
    }
    
    // get url
    NSURL* hyperlink = [NSURL URLWithString:actionUrl];
    if (!hyperlink) {
        return NO;
    }
    
    // get entryKey(host+path)
    NSString* entryKey = [NSString stringWithFormat:@"%@%@", hyperlink.host, hyperlink.path];
    if (!entryKey || [entryKey length] <= 0) {
        return NO;
    }
    
    // get entry class name
    NSString* entryClassName = [self.entryMap valueForKey:entryKey];
    if (!entryClassName || [entryClassName length] <= 0) {
        return NO;
    }
    
    // make entry class
    Class entryClass = NSClassFromString(entryClassName);
    if(entryClass) {
        id<HAURLActionDelegate> delegate = [[entryClass alloc] init];
        NSMutableDictionary* queryDic = [HAURLUtil decomposeUrl:[hyperlink query]];
        return [delegate performWithUrl:actionUrl entryKey:entryKey queryDic:queryDic];
    }
    
    return NO;
}

@end

/**
 * HAURLActionObject
 */
@implementation HAURLActionObject

- (BOOL) performWithUrl:(NSString*)actionUrl
{
    // url协议为空
    if (!self.protocol || [self.protocol length] <= 0) {
        return NO;
    }
    
    // action 为空
    if (!actionUrl || [actionUrl length] <= 0) {
        return NO;
    }
    
    // url协议不匹配
    NSRange range = [actionUrl rangeOfString:self.protocol];
    if (range.location == NSNotFound) {
        return NO;
    }
    
    // get url
    NSURL* hyperlink = [NSURL URLWithString:actionUrl];
    if (!hyperlink) {
        return NO;
    }
    
    // get entryKey(host+path)
    NSString* entryKey = [NSString stringWithFormat:@"%@%@", hyperlink.host, hyperlink.path];
    if (!entryKey || [entryKey length] <= 0) {
        return NO;
    }
    
    if (![self.entryKey isEqualToString:entryKey]) {
        return NO;
    }
    
    NSMutableDictionary* queryDic = [HAURLUtil decomposeUrl:[hyperlink query]];
    
    return [self.actionDelegate performWithUrl:actionUrl entryKey:entryKey queryDic:queryDic];
}

@end
