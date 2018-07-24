//
//  LayoutContainer.m
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

#import "LayoutContainer.h"
#import "UIView+Layout.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

/**
 * LayoutParams
 */
@implementation LayoutParams
@synthesize visible = _visible;
@synthesize measuredWidth = _measuredWidth;
@synthesize measuredHeight = _measuredHeight;

- (id)init
{
    self = [super init];
    if (self) {
        self.minWidth = FLT_MIN;
        self.minHeight = FLT_MIN;
    }
    
    return self;
}

- (void) setVisible:(int)visible
{
    if (visible == VISIBLE) {
        self.attachView.hidden = NO;
    }
    else {
        self.attachView.hidden = YES;
    }
    
    _visible = visible;
}

- (void) setMeasuredDimension:(MeasuredDimension)width height:(MeasuredDimension)height
{
    _measuredWidth = width;
    _measuredHeight = height;
}

// 将宽高两个state拼在一起
- (int)getMeasuredState
{
    return (self.measuredWidth.state) | ((self.measuredHeight.state >> MEASURED_HEIGHT_STATE_SHIFT) & (MEASURED_STATE_MASK >> MEASURED_HEIGHT_STATE_SHIFT));
}

- (float) getMeasuredWidth
{
    return self.measuredWidth.size;
}

- (float) getMeasuredHeight
{
    return self.measuredHeight.size;
}

- (float)getSuggestedMinimumWidth
{
    return self.minWidth;
}

- (float)getSuggestedMinimumHeight
{
    return self.minHeight;
}

@end

/**
 * MarginLayoutParams
 */
@implementation MarginLayoutParams


@end

/**
 * LayoutContainer
 */
@implementation LayoutContainer
- (id)init
{
    self = [super init];
    if (self) {
        self.limitChild = YES;
    }
    
    return self;
}

#pragma mark - 在布局过程中使用，外部不要调用
+ (MeasureSpec) getRootMeasureSpec:(float)windowSize rootDimension:(float)rootDimension
{
    MeasureSpec measureSpec;
    if (rootDimension == MATCH_PARENT) {
        // Window can't resize. Force root view to be windowSize.
        measureSpec.size = windowSize;
        measureSpec.mode = EXACTLY;
    }
    else if (rootDimension == WRAP_CONTENT) {
        // Window can resize. Set max size for root view.
        // dong 修改AT_MOST为UNSPECTIFIED
        measureSpec.size = 0;
        measureSpec.mode = UNSPECIFIED;
    }
    else {
        // Window wants to be an exact size. Force root view to be that size.
        measureSpec.size = rootDimension;
        measureSpec.mode = EXACTLY;
    }
    
    return measureSpec;
}

+ (float) getDefaultSize:(float)size measureSpec:(MeasureSpec)measureSpec
{
    float result = size;
    int specMode = measureSpec.mode;
    float specSize = measureSpec.size;
    
    switch (specMode) {
        case UNSPECIFIED:
            result = size;
            break;
        case AT_MOST:
        case EXACTLY:
            result = specSize;
            break;
    }
    
    return result;
}

+ (int)combineMeasuredStates:(int)curState newState:(int)newState
{
    return curState | newState;
}

+ (float)resolveSize:(float)size measureSpec:(MeasureSpec)measureSpec
{
    return [self resolveSizeAndState:size measureSpec:measureSpec childMeasuredState:0].size;
}

+ (MeasuredDimension)resolveSizeAndState:(float)size measureSpec:(MeasureSpec)measureSpec childMeasuredState:(int)childMeasuredState
{
    float result = size;
    int specMode = measureSpec.mode;
    float specSize = measureSpec.size;
    int state = 0;
    switch (specMode) {
        case UNSPECIFIED:
            result = size;
            break;
        case AT_MOST:
            if (specSize < size) {
                result = specSize;
                state = MEASURED_STATE_TOO_SMALL;
            }
            else {
                result = size;
            }
            break;
        case EXACTLY:
            result = specSize;
            break;
    }
    
    MeasuredDimension measuredDimension;
    measuredDimension.size = result;
    measuredDimension.state = state | (childMeasuredState & MEASURED_STATE_MASK);
    return measuredDimension;
}

#pragma mark measure child
- (void) measureChildren:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            [self measureChild:child parentWidthMeasureSpec:widthMeasureSpec parentHeightMeasureSpec:heightMeasureSpec];
        }
    }
}

- (void) measureChild:(UIView*)child parentWidthMeasureSpec:(MeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(MeasureSpec)parentHeightMeasureSpec
{
    LayoutParams* lp = child.layoutParams;
    
    MeasureSpec childWidthMeasureSpec = [self getChildMeasureSpec:parentWidthMeasureSpec
                                                          padding:self.paddingLeft + self.paddingRight
                                                   childDimension:lp.width];
    MeasureSpec childHeightMeasureSpec = [self getChildMeasureSpec:parentHeightMeasureSpec
                                                           padding:self.paddingTop + self.paddingBottom
                                                    childDimension:lp.height];
    
    [child measure:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void) measureChildWithMargins:(UIView*)child
          parentWidthMeasureSpec:(MeasureSpec)parentWidthMeasureSpec
                       widthUsed:(float)widthUsed
         parentHeightMeasureSpec:(MeasureSpec)parentHeightMeasureSpec
                      heightUsed:(float)heightUsed
{
    MarginLayoutParams* lp = (MarginLayoutParams*)child.layoutParams;
    
    MeasureSpec childWidthMeasureSpec = [self getChildMeasureSpec:parentWidthMeasureSpec
                                                          padding:self.paddingLeft + self.paddingRight + lp.leftMargin + lp.rightMargin + widthUsed
                                                   childDimension:lp.width];
    MeasureSpec childHeightMeasureSpec = [self getChildMeasureSpec:parentHeightMeasureSpec
                                                           padding:self.paddingTop + self.paddingBottom + lp.topMargin + lp.bottomMargin + heightUsed
                                                    childDimension:lp.height];
    
    [child measure:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (MeasureSpec) getChildMeasureSpec:(MeasureSpec)spec padding:(float)padding childDimension:(float)childDimension
{
    int specMode = spec.mode;
    float specSize = spec.size;
    
    float size = MAX(0.0f, specSize - padding);
    
    float resultSize = 0;
    int resultMode = 0;
    
    switch (specMode) {
            // Parent has imposed an exact size on us
        case EXACTLY:
            if (childDimension >= 0) {
                resultSize = childDimension;
                resultMode = EXACTLY;
            } else if (childDimension == MATCH_PARENT) {
                // Child wants to be our size. So be it.
                resultSize = size;
                resultMode = EXACTLY;
            } else if (childDimension == WRAP_CONTENT) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                resultSize = size;
                // dong 原来是：resultMode = AT_MOST;
                if (self.limitChild) {
                    resultMode = AT_MOST;
                }
                else {
                    resultMode = UNSPECIFIED;
                }
            }
            break;
            
            // Parent has imposed a maximum size on us
        case AT_MOST:
            if (childDimension >= 0) {
                // Child wants a specific size... so be it
                resultSize = childDimension;
                resultMode = EXACTLY;
            } else if (childDimension == MATCH_PARENT) {
                // Child wants to be our size, but our size is not fixed.
                // Constrain child to not be bigger than us.
                resultSize = size;
                resultMode = AT_MOST;
            } else if (childDimension == WRAP_CONTENT) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                resultSize = size;
                // dong 原来是：resultMode = AT_MOST;
                if (self.limitChild) {
                    resultMode = AT_MOST;
                }
                else {
                    resultMode = UNSPECIFIED;
                }
            }
            break;
            
            // Parent asked to see how big we want to be
        case UNSPECIFIED:
            if (childDimension >= 0) {
                // Child wants a specific size... let him have it
                resultSize = childDimension;
                resultMode = EXACTLY;
            } else if (childDimension == MATCH_PARENT) {
                // Child wants to be our size... find out how big it should
                // be
                resultSize = 0;
                resultMode = UNSPECIFIED;
            } else if (childDimension == WRAP_CONTENT) {
                // Child wants to determine its own size.... find out how
                // big it should be
                resultSize = 0;
                resultMode = UNSPECIFIED;
            }
            break;
    }
    
    MeasureSpec measureSpec;
    measureSpec.size = resultSize;
    measureSpec.mode = resultMode;
    return measureSpec;
}

// 外部调用
- (MarginLayoutParams*)makeChildLayoutParams
{
    return [[MarginLayoutParams alloc] init];
}

#pragma mark - notification
- (void) onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    MeasuredDimension widthDimension;
    widthDimension.state = 0;
    widthDimension.size = [LayoutContainer getDefaultSize:[self.attachView.layoutParams getSuggestedMinimumWidth] measureSpec:widthMeasureSpec];
    
    MeasuredDimension heightDimension;
    heightDimension.state = 0;
    heightDimension.size = [LayoutContainer getDefaultSize:[self.attachView.layoutParams getSuggestedMinimumHeight] measureSpec:heightMeasureSpec];
    
    [self.attachView.layoutParams setMeasuredDimension:widthDimension height:heightDimension];
}

- (void) onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
    
}

- (void) onRemoveSubview:(UIView*)subView
{
    
}

@end
