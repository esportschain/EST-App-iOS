//
//  HANotificationCenter.m
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

#import "HANotificationCenter.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

/**
 * HANotificationBlock
 */
@interface HANotificationBlockObserver : NSObject
@property(nonatomic, weak) id observer;
@property(nonatomic, copy) NSString* key;
@property(nonatomic, strong) id userInfo;
@property(nonatomic, copy) HANotificationBlock block;

- (BOOL)isEqual:(NSString*)key observer:(id)observer;
- (void) perform:(id)params;
@end

@implementation HANotificationBlockObserver

- (BOOL)isEqual:(NSString*)key observer:(id)observer
{
    return NO;
}

- (void) perform:(id)params
{
    if (self.block) {
        self.block(params, self.userInfo);
    }
}

@end

/**
 * HANotificationCenter
 */
static NSLock *readLock = nil;
@interface HANotificationCenter()
@property(nonatomic, strong)NSMutableDictionary<NSString*, NSMutableArray*> *notificationObserverMap;
@end

@implementation HANotificationCenter
SYNTHESIZE_SINGLETON_FOR_CLASS(HANotificationCenter);

#pragma mark - View lifecycle
- (id)init
{
    self = [super init];
    if(self) {
        readLock = [[NSLock alloc] init];
        self.notificationObserverMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addNotificationObserver:(id)observer notificationKey:(NSString*)key observerBlock:(HANotificationBlock)block userInfo:(id)userInfo
{
    [readLock lock];
    
    NSMutableArray* observersArray = [self getObserversArray:key observer:observer];
    if(observersArray) {
        HANotificationBlockObserver* notificationObserver = [[HANotificationBlockObserver alloc] init];
        notificationObserver.key = key;
        notificationObserver.observer = observer;
        notificationObserver.block = block;
        notificationObserver.userInfo = userInfo;
        [observersArray addObject:notificationObserver];
    }
    
    [readLock unlock];
}

- (BOOL)removeNotificationObserver:(id)observer notificationKey:(NSString*)key
{
    BOOL isRemoved = NO;
    
    [readLock lock];
    
    NSMutableArray* observersArray = [self.notificationObserverMap objectForKey:key];
    if(observersArray != nil) {
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:observersArray];
        for (HANotificationBlockObserver* observerItem in tempArray) {
            if ([[observerItem observer] isEqual:observer] && [[observerItem key] isEqualToString:key]) {
                [observersArray removeObject:observerItem];
                isRemoved = YES;
            }
        }
        
        if([observersArray count] == 0) {
            [self.notificationObserverMap removeObjectForKey:key];
        }
    }
    
    [readLock unlock];
    
    return isRemoved;
}

- (BOOL)removeNotificationObserver:(id)observer
{
    BOOL isRemoved = NO;
    
    [readLock lock];
    
    NSArray* allKeys = [self.notificationObserverMap allKeys];
    for (NSString* key in allKeys) {
        NSMutableArray* observers = [self.notificationObserverMap valueForKey:key];
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:observers];
        for (HANotificationBlockObserver* observerItem in tempArray) {
            if ([[observerItem observer] isEqual:observer]) {
                [observers removeObject:observerItem];
                isRemoved = YES;
            }
        }
        
        if([observers count] == 0) {
            [self.notificationObserverMap removeObjectForKey:key];
        }
    }
    
    [readLock unlock];
    
    return isRemoved;
}

- (void)removeAllNotificationObservers
{
    [readLock lock];
    
    [self.notificationObserverMap removeAllObjects];
    
    [readLock unlock];
}

- (void)postNotification:(NSString*)key params:(id)params
{
    [readLock lock];
    
    NSMutableArray* observersArray = [self.notificationObserverMap objectForKey:key];
    if(observersArray != nil) {
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:observersArray];
        for (HANotificationBlockObserver* observerItem in tempArray) {
            [observerItem perform:params];
        }
    }
    
    [readLock unlock];
}

#pragma mark - private
-(NSMutableArray*) getObserversArray:(NSString*)key observer:(id)observer
{
    NSMutableArray* observersArray = [self.notificationObserverMap objectForKey:key];
    if(!observersArray) {
        observersArray = [NSMutableArray array];
        [self.notificationObserverMap setValue:observersArray forKey:key];
    }
    
    BOOL shouldAdd = YES;
    for (HANotificationBlockObserver* notificationObserver in observersArray) {
        if ([notificationObserver isEqual:key observer:observer]) {
            shouldAdd = NO;
            break;
        }
    }
    
    if (shouldAdd) {
        return observersArray;
    }
    
    return nil;
}

@end
