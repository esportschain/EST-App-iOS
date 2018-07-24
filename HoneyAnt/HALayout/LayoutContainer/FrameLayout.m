//
//  FrameLayout.m
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

#import "FrameLayout.h"
#import "UIView+Layout.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

/**
 * FrameLayoutParams
 */
@implementation FrameLayoutParams

- (id)init
{
    self = [super init];
    if (self) {
        self.gravity = -1;
    }
    
    return self;
}

@end

/**
 * FrameLayout
 */
@interface FrameLayout()
{
    NSMutableArray* _matchParentChildren;
}

@end

@implementation FrameLayout

+(FrameLayout*) layout
{
    FrameLayout* instance = [[FrameLayout alloc] init];
    if (instance) {
        
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _matchParentChildren = [[NSMutableArray alloc] initWithCapacity:16];
    }
    
    return self;
}

#pragma mark - measure
- (void) onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    BOOL measureMatchParentChildren = widthMeasureSpec.mode != EXACTLY || heightMeasureSpec.mode != EXACTLY;
    
    [_matchParentChildren removeAllObjects];
    
    float maxHeight = 0;
    float maxWidth = 0;
    int childState = 0;
    
    for (UIView* child in self.attachView.subviews) {
        if (self.measureAllChildren || child.layoutParams.visible != GONE) {
            [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
            FrameLayoutParams* lp = (FrameLayoutParams*)child.layoutParams;
            maxWidth = MAX(maxWidth,
                           [lp getMeasuredWidth] + lp.leftMargin + lp.rightMargin);
            maxHeight = MAX(maxHeight,
                            [lp getMeasuredHeight] + lp.topMargin + lp.bottomMargin);
            childState = [LayoutContainer combineMeasuredStates:childState newState:[lp getMeasuredState]];
            if (measureMatchParentChildren) {
                if (lp.width == MATCH_PARENT || lp.height == MATCH_PARENT) {
                    [_matchParentChildren addObject:child];
                }
            }
        }
    }
    
    // Account for padding too
    maxWidth += self.paddingLeft + self.paddingRight;
    maxHeight += self.paddingTop + self.paddingBottom;
    
    // Check against our minimum height and width
    maxHeight = MAX(maxHeight, [self.attachView.layoutParams getSuggestedMinimumHeight]);
    maxWidth = MAX(maxWidth, [self.attachView.layoutParams getSuggestedMinimumWidth]);
    
    [self.attachView.layoutParams setMeasuredDimension:[LayoutContainer resolveSizeAndState:maxWidth measureSpec:widthMeasureSpec childMeasuredState:childState]
                        height:[LayoutContainer resolveSizeAndState:maxHeight measureSpec:heightMeasureSpec childMeasuredState:childState << MEASURED_HEIGHT_STATE_SHIFT]];
    
    if ([_matchParentChildren count] > 1) {
        for (UIView* child in _matchParentChildren) {
            FrameLayoutParams* lp = (FrameLayoutParams*)child.layoutParams;
            MeasureSpec childWidthMeasureSpec;
            MeasureSpec childHeightMeasureSpec;
            
            if (lp.width == MATCH_PARENT) {
                childWidthMeasureSpec.size = [self.attachView.layoutParams getMeasuredWidth] - self.paddingLeft - self.paddingRight - lp.leftMargin - lp.rightMargin;
                childWidthMeasureSpec.mode = EXACTLY;
            } else {
                childWidthMeasureSpec = [self getChildMeasureSpec:widthMeasureSpec
                                                          padding:self.paddingLeft + self.paddingRight + lp.leftMargin + lp.rightMargin
                                                   childDimension:lp.width];
            }
            
            if (lp.height == MATCH_PARENT) {
                childHeightMeasureSpec.size = [self.attachView.layoutParams getMeasuredHeight] - self.paddingTop - self.paddingBottom - lp.topMargin - lp.bottomMargin;
                childHeightMeasureSpec.mode = EXACTLY;
            } else {
                childHeightMeasureSpec = [self getChildMeasureSpec:heightMeasureSpec
                                                           padding:self.paddingTop + self.paddingBottom + lp.topMargin + lp.bottomMargin
                                                    childDimension:lp.height];
            }
            
            [child measure:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
        }
    }
}

#pragma mark - layout
- (void) onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
    float parentLeft = self.paddingLeft;
    float parentRight = right - left - self.paddingRight;
    
    float parentTop = self.paddingTop;
    float parentBottom = bottom - top - self.paddingBottom;
    
    
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            FrameLayoutParams* lp = (FrameLayoutParams*)child.layoutParams;
            float width = [lp getMeasuredWidth];
            float height = [lp getMeasuredHeight];
            
            float childLeft;
            float childTop;
            
            int gravity = lp.gravity;
            if (gravity == -1) {
                gravity = GRAVITY_TOP | GRAVITY_LEFT;
            }
            if (gravity & GRAVITY_CENTER_HORIZONTAL) {
                childLeft = parentLeft + (parentRight - parentLeft - width) / 2 + lp.leftMargin - lp.rightMargin;
            }
            else if (gravity & GRAVITY_RIGHT) {
                childLeft = parentRight - width - lp.rightMargin;
            }
            else {
                childLeft = parentLeft + lp.leftMargin;
            }
            
            if (gravity & GRAVITY_CENTER_VERTICAL) {
                childTop = parentTop + (parentBottom - parentTop - height) / 2 + lp.topMargin - lp.bottomMargin;
            }
            else if (gravity & GRAVITY_BOTTOM) {
                childTop = parentBottom - height - lp.bottomMargin;
            }
            else {
                childTop = parentTop + lp.topMargin;
            }
            
            [child layout:childLeft top:childTop right:childLeft + width bottom:childTop + height];
        }
    }
}

- (MarginLayoutParams*)makeChildLayoutParams
{
    return [[FrameLayoutParams alloc] init];
}

@end
