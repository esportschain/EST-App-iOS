//
//  UIBarButtonItem+Extension.h
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

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action Image:(NSString *)image HighImage:(NSString *)highImage;
+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)tilte norImage:(NSString *)norImage higImage:(NSString *)higImage titleColor:(UIColor *)titleColor tagert:(id)target action:(SEL)action;
@end
