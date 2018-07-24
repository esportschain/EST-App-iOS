//
//  HAColorUtil.m
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

#import "HAColorUtil.h"
#import <QuartzCore/CALayer.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation HAColorUtil

+ (UIColor*)colorWithRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b alpha:(NSInteger)a
{
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
}

+ (UIColor*)colorWithInt:(NSInteger)c
{
    unsigned int color = (unsigned int)c;
    int b = color % 256;
    int g = color / 256 % 256;
    int r = color / 256 / 256 % 256;
    int a = color / 256 / 256 / 256 % 256;
    
    if (a == 0) {
        a = 255;
    }
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
}

@end
