//
//  HADataWrapper.m
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

#import "HADataWrapper.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface HADataWrapper()
@property(nonatomic, strong)id object;
@end

@implementation HADataWrapper
- (id)copyWithZone:(NSZone*)zone
{
    HADataWrapper *result = [[[self class] allocWithZone:zone] init];
    result.object = self.object;
    return result;
}

- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[HADataWrapper class]]) {
        return self.object == [anObject object];
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.object hash];
}

- (NSString*)description
{
    return [self.object description];
}

+ (HADataWrapper*)dataWrapperWithObject:(id)object
{
    HADataWrapper *jsonObj = [[HADataWrapper alloc] init];
    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
        jsonObj.object = object;
    }
    
    return jsonObj;
}

+ (HADataWrapper*)dataWrapperWithJsonData:(NSData*)data
{
    return [HADataWrapper dataWrapperWithObject:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
}

- (NSUInteger)count
{
    NSUInteger ret = 0;
    
    if ([self.object respondsToSelector:@selector(count)]) {
        ret = [self.object count];
    }
    
    return ret;
}

- (id)getObject
{
    return self.object;
}

- (NSString*)toString
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.object options:0 error:&error];
    
    NSString *stringData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return stringData;
}

- (void)printObject
{
    NSLog(@"object is:\r\n %@", self.object);
}

#pragma mark - for NSDictionary
- (HADataWrapper*)dataWrapperForKey:(NSString*)key
{
    id retObj = nil;
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)self.object;
        retObj = [dict objectForKey:key];
    }
    
    if (retObj == nil) {
        retObj = [NSDictionary dictionary];
    }
    
    return [HADataWrapper dataWrapperWithObject:retObj];
}

- (NSString*)stringForKey:(NSString*)key
{
    id retObj = [NSString string];
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)self.object;
        retObj = [dict objectForKey:key];
        
        if ([retObj isKindOfClass:[NSNumber class]]) {
            retObj = [retObj stringValue];
        }
        
        if (![retObj isKindOfClass:[NSString class]]) {
            retObj = [NSString string];
        }
    }
    
    return retObj;
}

- (int)intForKey:(NSString*)key
{
    return [[self stringForKey:key] intValue];
}

- (long long)longLongForKey:(NSString*)key
{
    return [[self stringForKey:key] longLongValue];
}

- (float)floatForKey:(NSString*)key
{
    return [[self stringForKey:key] floatValue];
}

- (double)doubleForKey:(NSString*)key
{
    return [[self stringForKey:key] doubleValue];
}

- (BOOL)boolForKey:(NSString*)key
{
    return [[self stringForKey:key] boolValue];
}

#pragma mark - for NSArray
- (HADataWrapper*)dataWrapperForIndex:(int)index
{
    id retObj = nil;
    if ([self.object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)self.object;
        if ([array count] > index) {
            retObj = [array objectAtIndex:index];
        }
    }
    
    if (retObj == nil) {
        retObj = [NSArray array];
    }
    
    return [HADataWrapper dataWrapperWithObject:retObj];
}

- (NSString*)stringForIndex:(int)index
{
    id retObj = [NSString string];
    if ([self.object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)self.object;
        if ([array count] > index) {
            retObj = [array objectAtIndex:index];
        }
        
        if ([retObj isKindOfClass:[NSNumber class]]) {
            retObj = [retObj stringValue];
        }
        
        if (![retObj isKindOfClass:[NSString class]]) {
            retObj = [NSString string];
        }
    }
    
    return retObj;
}

- (int)intForIndex:(int)index
{
    return [[self stringForIndex:index] intValue];
}

- (long long)longLongForIndex:(int)index
{
    return [[self stringForIndex:index] longLongValue];
}

- (float)floatForIndex:(int)index
{
    return [[self stringForIndex:index] floatValue];
}

- (double)doubleForIndex:(int)index
{
    return [[self stringForIndex:index] doubleValue];
}

- (BOOL)boolForIndex:(int)index
{
    return [[self stringForIndex:index] boolValue];
}

@end
