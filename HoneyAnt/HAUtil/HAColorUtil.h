//
//  HAColorUtil.h
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
#import <UIKit/UIKit.h>
#import "HAObject.h"

@interface HAColorUtil : HAObject

// colorWithRed:255 green:255 blue:255 alpha:255 colorWithRed:0xff green:0xff blue:0xff alpha:0xff
+ (UIColor*)colorWithRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b alpha:(NSInteger)a;

// (argb) colorWithInt:0xffffff colorWithInt:0x77ffffff
+ (UIColor*)colorWithInt:(NSInteger)c;

@end


