//
//  HADataWrapper.h
//  NSDictionary或NSArray封装类，安全读取
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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "HAObject.h"

@interface HADataWrapper : HAObject <NSCopying>

// attach object
+ (HADataWrapper*)dataWrapperWithObject:(id)object;
+ (HADataWrapper*)dataWrapperWithJsonData:(NSData*)data;

// 获取关联的NSDictionary或NSArray子元素数量
- (NSUInteger)count;

// 获取关联的NSDictionary或NSArray
- (id)getObject;

// 将关联的NSDictionary或NSArray转为字符串输出
- (NSString*)toString;

// 打印关联的NSDictionary或NSArray
- (void)printObject;

// 对NSDictionary操作
- (HADataWrapper*)dataWrapperForKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (long long)longLongForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;

// 对NSArray操作
- (HADataWrapper*)dataWrapperForIndex:(int)index;
- (NSString*)stringForIndex:(int)index;
- (int)intForIndex:(int)index;
- (long long)longLongForIndex:(int)index;
- (float)floatForIndex:(int)index;
- (double)doubleForIndex:(int)index;
- (BOOL)boolForIndex:(int)index;

@end
