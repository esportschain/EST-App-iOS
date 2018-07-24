//
//  UIBarButtonItem+Extension.m
//  aimdev
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

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)
+(UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action Image:(NSString *)image HighImage:(NSString *)highImage
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)tilte norImage:(NSString *)norImage higImage:(NSString *)higImage titleColor:(UIColor *)titleColor tagert:(id)target action:(SEL)action
{
    // 创建按钮
    UIButton *btn = [[UIButton alloc] init];
    // 设置按钮属性
    if (tilte != nil && ![tilte isEqualToString:@""]) {
        [btn setTitle:tilte forState:UIControlStateNormal];
    }
    
    if (norImage != nil && ![norImage isEqualToString:@""]) {
        [btn setImage:[UIImage imageNamed:norImage] forState:UIControlStateNormal];
    }
    
    if (higImage != nil && ![higImage isEqualToString:@""]) {
        [btn setImage:[UIImage imageNamed:higImage] forState:UIControlStateHighlighted];
    }
    
    if (titleColor != nil) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }
    [btn.titleLabel setFont:kNormalFont(16)];
    [btn setTitleColor:kColor999999 forState:UIControlStateDisabled];
    // 设置size
    [btn sizeToFit];
    
    // 添加方法
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    // 返回自定义UIBarButtonItem
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
