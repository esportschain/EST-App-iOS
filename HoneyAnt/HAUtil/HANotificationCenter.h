//
//  HANotificationCenter.h
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
#import "SynthesizeSingleton.h"
#import "HAObject.h"

/**
 * block
 */
typedef void (^HANotificationBlock)(id params, id userInfo);

/**
 * HANotificationCenter
 * 所有加入的监听对象都为弱引用，可以不用移除
 */
@interface HANotificationCenter : HAObject

// observer is weak object
- (void)addNotificationObserver:(id)observer notificationKey:(NSString*)key observerBlock:(HANotificationBlock)block userInfo:(id)userInfo;
- (BOOL)removeNotificationObserver:(id)observer notificationKey:(NSString*)key;
- (BOOL)removeNotificationObserver:(id)observer;
- (void)removeAllNotificationObservers;
- (void)postNotification:(NSString*)key params:(id)params;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HANotificationCenter);

@end


