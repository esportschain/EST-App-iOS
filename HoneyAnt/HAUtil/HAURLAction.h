//
//  HAURLAction.h
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

/** url各部份定义
 http://example.com:80/docs/books/tutorial/index.html?name=networking#DOWNLOADING
 protocol = http
 authority = example.com:80
 host = example.com
 port = 80
 path = /docs/books/tutorial/index.html
 query = name=networking
 filename = /docs/books/tutorial/index.html?name=networking
 ref = DOWNLOADING
 */

#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"
#import "HAObject.h"

/*======== url action处理中心，以新建执行对象方式实现监听所有设到protocol里的url重定向事件 ===========*/
/**
 * HAURLActionDelegate
 */
@protocol HAURLActionDelegate <NSObject>
@required
- (BOOL) performWithUrl:(NSString*)actionUrl entryKey:(NSString*)entryKey queryDic:(NSMutableDictionary*)queryDic;
@end

/**
 * HAURLActionCenter
 */
@interface HAURLActionCenter : HAObject
@property(nonatomic, strong) NSMutableArray* actionProtocolArray; // HAURLActionCenterProtocol array
- (BOOL) performWithUrl:(NSString*)actionUrl;
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HAURLActionCenter);
@end

/**
 * HAURLActionCenterProtocol
 */
@interface HAURLActionCenterProtocol : HAObject
@property(nonatomic, strong) NSString* protocol; // url protocol
@property(nonatomic, strong) NSMutableDictionary* entryMap; // host+path => classname (home/nav/index.php => HomeVC)
- (BOOL) performWithUrl:(NSString*)actionUrl;
@end

/*=================== url action处理类，在一个实例化的对象中处理某个key对应的url重定向事件 =========================*/
/*=== 与HAURLActionCenter的区别是：HAURLActionCenterDelegate执行的时候只能新建对象，而不能以当前对象为基础执行操作 ===*/
/**
 * HAURLActionObject
 */
@interface HAURLActionObject : HAObject
@property(nonatomic, assign) id<HAURLActionDelegate> actionDelegate;
@property(nonatomic, strong) NSString* protocol; // url protocol
@property(nonatomic, strong) NSString* entryKey; // host+path
- (BOOL) performWithUrl:(NSString*)actionUrl;
@end




