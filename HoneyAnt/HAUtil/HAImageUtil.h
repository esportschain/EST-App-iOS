//
//  HAImageUtil.h
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

@interface HAImageUtil : HAObject

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGFloat)size;
+ (UIImage*)imageWithWidth:(NSInteger)width height:(NSInteger)height imgInfo:(unsigned char*)imgPixel;
+ (UIImage*)captureViewImage:(UIView*)view;
+ (UIImage*)scaleImage:(UIImage*)image inSize:(CGSize)size;
+ (UIImage*)fitImage:(UIImage*)image inSize:(CGSize)size;
+ (CGSize)fitSize:(UIImage*)image inSize:(CGSize)size;
+ (UIImage*)fixOrientation:(UIImage*)aImage;

@end


