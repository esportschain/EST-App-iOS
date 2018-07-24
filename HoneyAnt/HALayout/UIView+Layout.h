//
//  UIView+Layout.h
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

#import <UIKit/UIKit.h>
#import "LayoutContainer.h"
#import "RelativeLayout.h"
#import "LinearLayout.h"
#import "FrameLayout.h"

/**
 * layout过程监听，可以在这里改变控件的默认衡量和布局方式
 */
@protocol onLayoutDelegate <NSObject>

@optional
- (void)onMeasure:(UIView*)view widthMeasureSpec:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec;
- (BOOL)onLayout:(UIView*)view left:(float)left top:(float)top right:(float)right bottom:(float)bottom;
- (void)onSizeChanged:(UIView*)view newWidth:(float)newWidth newHeight:(float)newHeight oldWidth:(float)oldWidth oldHeight:(float)oldHeight;

@end

/**
 * build容器/控件时所用的block回调，在block中完善以下属性，看起来比较整齐
 *
 * 此处参数用id的好处是在block体实现时可以直接写真正的参数类型，而不是在代码中用基类强转，如：
 * [UILabel build:layout config:^(LinearLayoutParams *params, UILabel  *layout) {...}];
 *
 * container:可以是RelativeLayout/FrameLayout/LinearLayout
 *
 * params:可以是MarginLayoutParams/RelativeLayoutParams/FrameLayoutParams/LinearLayoutParams
 *
 * layout:用build函数构造出来的控件对象
 */
typedef void (^LayoutContainerConfig)(id container, id params, id layout);
typedef void (^LayoutConfig)(id params, id layout);

/**
 * 支持类似于Android的布局方式
 */
@interface UIView (Layout)

// 为方便设置或获取控件大小位置而做的扩展
@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat right;
@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, assign) CGPoint origin;
@property(nonatomic, assign) CGSize  size;

// 布局参数
@property(nonatomic, strong, readonly) MarginLayoutParams* layoutParams;

// 布局容器，仅当此View作为容器使用时，需要此参数
@property(nonatomic, strong, readonly) LayoutContainer* layoutContainer;

// 布局过程回调，实现回调方法，修改默认布局方式
@property(nonatomic, weak) id<onLayoutDelegate> layoutDelegate;

// 用户设定的数据，可以绑定任意类型数据
@property(nonatomic, strong) NSObject* userInfo;

// 做为容器初始化
+ (id)build:(UIView*)parent container:(LayoutContainer*)container config:(LayoutContainerConfig)config;

// 做为控件初始化
+ (id)build:(UIView*)parent config:(LayoutConfig)config;

// 扩展UIView的功能，删除子View。如此控件中使用相对布局容器，需要调以下方法移除子控件，不要调用removeFromSuperview
- (void)removeSubviewAtIndex:(NSInteger)index;
- (void)removeSubview:(UIView*)subView;

// 更新子控件的布局，外部调用
- (void)requestLayout;

// 内部布局，外部不要调用
- (void)measure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec;
- (void)layout:(float)left top:(float)top right:(float)right bottom:(float)bottom;

// 布局回调
- (void)onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec;
- (BOOL)onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom;
- (void)onSizeChanged:(float)newWidth newHeight:(float)newHeight oldWidth:(float)oldWidth oldHeight:(float)oldHeight;

// 根据控件宽度和内容宽高，按比例设置控件高度
- (void)scaleAspectFitHeight:(CGSize)contentSize viewWidth:(CGFloat)width;

@end
