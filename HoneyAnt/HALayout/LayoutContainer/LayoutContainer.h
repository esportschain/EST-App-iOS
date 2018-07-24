//
//  LayoutContainer.h
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

/**
 * width & height
 */
#define MATCH_PARENT  -1
#define WRAP_CONTENT  -2

/**
 * measure size & state
 */
#define MEASURED_SIZE_MASK          0x00ffffff
#define MEASURED_STATE_MASK         0xff000000
#define MEASURED_STATE_TOO_SMALL    0x01000000
#define MEASURED_HEIGHT_STATE_SHIFT 16

/**
 * visible
 */
#define VISIBLE     0x00000000
#define INVISIBLE   0x00000004
#define GONE        0x00000008

/**
 * gravity
 */
#define GRAVITY_LEFT                (0x00000001)
#define GRAVITY_CENTER_HORIZONTAL   (0x00000001 << 1)
#define GRAVITY_RIGHT               (0x00000001 << 2)
#define GRAVITY_TOP                 (0x00000001 << 3)
#define GRAVITY_CENTER_VERTICAL     (0x00000001 << 4)
#define GRAVITY_BOTTOM              (0x00000001 << 5)

/**
 * 衡量模式
 */
#define MODE_SHIFT  30
#define MODE_MASK   (0x3 << MODE_SHIFT)
#define UNSPECIFIED (0 << MODE_SHIFT)   // 未指定尺寸，这种情况不多，一般都是父控件是AdapterView，通过measure方法传入的模式
#define EXACTLY     (1 << MODE_SHIFT)   // 当控件的layout_width或layout_height指定为具体数值时
#define AT_MOST     (2 << MODE_SHIFT)   // 根据内容设定自身大小：WRAP_CONTENT

/**
 * 衡量过程中用到的的控件的大小和模式
 */
typedef struct {
    float   size;   // 衡量大小
    int     mode;   // 衡量模式
} MeasureSpec;

/**
 * 衡量出来的控件的大小和状态
 */
typedef struct {
    float   size;   // 衡量大小
    int     state;  // 衡量状态
} MeasuredDimension;

/**
 * LayoutParams
 */
@interface LayoutParams : HAObject

// 控件的可视化属性：VISIBLE（可见）/INVISIBLE（不可见，但仍占位）/GONE（不可见，且不占位）
@property(nonatomic, assign) int visible;

// 关联的布局控件，控件中寄存了LayoutContainer，此处弱引用一下关联的UIView
@property(nonatomic, weak) UIView* attachView;

// dimension
@property(nonatomic, assign) float width; // >=0.0f的具体数值或MATCH_PARENT/WRAP_CONTENT
@property(nonatomic, assign) float height; // >=0.0f的具体数值或MATCH_PARENT/WRAP_CONTENT

// min & max dimension
@property(nonatomic, assign) float minWidth; // >=0.0f的具体数值
@property(nonatomic, assign) float minHeight; // >=0.0f的具体数值
- (float) getSuggestedMinimumWidth;
- (float) getSuggestedMinimumHeight;

// 衡量出来的控件的大小和状态
@property(nonatomic, assign, readonly) MeasuredDimension measuredWidth;
@property(nonatomic, assign, readonly) MeasuredDimension measuredHeight;
- (void)setMeasuredDimension:(MeasuredDimension)width height:(MeasuredDimension)height;
- (int)getMeasuredState;
- (float)getMeasuredWidth;
- (float)getMeasuredHeight;

@end

/**
 * MarginLayoutParams
 */
@interface MarginLayoutParams : LayoutParams
@property(nonatomic, assign) float leftMargin;
@property(nonatomic, assign) float rightMargin;
@property(nonatomic, assign) float topMargin;
@property(nonatomic, assign) float bottomMargin;

@end

/**
 * LayoutContainer
 */
@interface LayoutContainer : HAObject

// 是否限制子控件总宽高不超过父控件宽高
@property(nonatomic, assign) BOOL limitChild;

// 容器的壁宽
@property(nonatomic, assign) float paddingLeft;
@property(nonatomic, assign) float paddingRight;
@property(nonatomic, assign) float paddingTop;
@property(nonatomic, assign) float paddingBottom;

// 关联的布局控件，控件中寄存了LayoutContainer，此处弱引用一下关联的UIView
@property(nonatomic, weak) UIView* attachView;

// 在布局过程中使用
+ (MeasureSpec)getRootMeasureSpec:(float)windowSize rootDimension:(float)rootDimension;
+ (float)getDefaultSize:(float)size measureSpec:(MeasureSpec)measureSpec;
+ (int)combineMeasuredStates:(int)curState newState:(int)newState;
+ (float)resolveSize:(float)size measureSpec:(MeasureSpec)measureSpec;
+ (MeasuredDimension)resolveSizeAndState:(float)size measureSpec:(MeasureSpec)measureSpec childMeasuredState:(int)childMeasuredState;

- (void)measureChildren:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec;
- (void)measureChild:(UIView*)child parentWidthMeasureSpec:(MeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(MeasureSpec)parentHeightMeasureSpec;
- (void)measureChildWithMargins:(UIView*)child parentWidthMeasureSpec:(MeasureSpec)parentWidthMeasureSpec widthUsed:(float)widthUsed parentHeightMeasureSpec:(MeasureSpec)parentHeightMeasureSpec heightUsed:(float)heightUsed;
- (MeasureSpec)getChildMeasureSpec:(MeasureSpec)spec padding:(float)padding childDimension:(float)childDimension;

// UIView调用
- (MarginLayoutParams*)makeChildLayoutParams;
- (void)onRemoveSubview:(UIView*)subView;
- (void)onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec;
- (void)onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom;

@end
