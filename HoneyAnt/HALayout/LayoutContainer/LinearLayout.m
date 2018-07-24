//
//  LinearLayout.m
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

#import "LinearLayout.h"
#import "UIView+Layout.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

#define INDEX_CENTER_VERTICAL   0
#define INDEX_TOP               1
#define INDEX_BOTTOM            2
#define INDEX_FILL              3

#define VERTICAL_GRAVITY_COUNT  4

/**
 * LinearLayoutParams
 */
@implementation LinearLayoutParams

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
 * LinearLayout
 */
@interface LinearLayout()
{
    float _totalLength;
    int _maxAscent[VERTICAL_GRAVITY_COUNT];
    int _maxDescent[VERTICAL_GRAVITY_COUNT];
}
@end

@implementation LinearLayout

+(LinearLayout*) layout
{
    LinearLayout* instance = [[LinearLayout alloc] init];
    if (instance) {
        
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.gravity = GRAVITY_LEFT | GRAVITY_TOP;
    }
    
    return self;
}

#pragma mark - measure
- (void) onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    if (self.orientation == VERTICAL) {
        [self measureVertical:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
    else {
        [self measureHorizontal:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
}

- (void) measureVertical:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    _totalLength = 0;
    float maxWidth = 0;
    int childState = 0;
    float alternativeMaxWidth = 0;
    float weightedMaxWidth = 0;
    BOOL allFillParent = YES;
    float totalWeight = 0;
    
    NSUInteger count = [self.attachView.subviews count];
    
    int widthMode = widthMeasureSpec.mode;
    int heightMode = heightMeasureSpec.mode;
    
    BOOL matchWidth = NO;
    
    float largestChildHeight = FLT_MIN;
    
    // See how tall everyone is. Also remember max width.
    for (int i = 0; i < count; i ++) {
        UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
        if (child == nil) {
            continue;
        }
        
        if (child.layoutParams.visible == GONE) {
            continue;
        }
        
        LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
        
        totalWeight += lp.weight;
        
        if (heightMode == EXACTLY && lp.height == 0 && lp.weight > 0) {
            // Optimization: don't bother measuring children who are going to use
            // leftover space. These views will get measured again down below if
            // there is any leftover space.
            float totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + lp.topMargin + lp.bottomMargin);
        } else {
            float oldHeight = FLT_MIN;
            
            if (lp.height == 0 && lp.weight > 0) {
                // heightMode is either UNSPECIFIED or AT_MOST, and this
                // child wanted to stretch to fill available space.
                // Translate that to WRAP_CONTENT so that it does not end up
                // with a height of 0
                oldHeight = 0;
                lp.height = WRAP_CONTENT;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self measureChildBeforeLayout:child childIndex:i widthMeasureSpec:widthMeasureSpec totalWidth:0 heightMeasureSpec:heightMeasureSpec totalHeight:(totalWeight == 0 ? _totalLength : 0)];
            
            if (oldHeight != FLT_MIN) {
                lp.height = oldHeight;
            }
            
            float childHeight = [lp getMeasuredHeight];
            float totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + childHeight + lp.topMargin + lp.bottomMargin);
            
            if (self.useLargestChild) {
                largestChildHeight = MAX(childHeight, largestChildHeight);
            }
        }
        
        BOOL matchWidthLocally = NO;
        if (widthMode != EXACTLY && lp.width == MATCH_PARENT) {
            // The width of the linear layout will scale, and at least one
            // child said it wanted to match our width. Set a flag
            // indicating that we need to remeasure at least that view when
            // we know our width.
            matchWidth = YES;
            matchWidthLocally = YES;
        }
        
        float margin = lp.leftMargin + lp.rightMargin;
        float measuredWidth = [lp getMeasuredWidth] + margin;
        maxWidth = MAX(maxWidth, measuredWidth);
        childState = [LayoutContainer combineMeasuredStates:childState newState:[lp getMeasuredState]];
        
        allFillParent = allFillParent && lp.width == MATCH_PARENT;
        if (lp.weight > 0) {
            /*
             * Widths of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxWidth = MAX(weightedMaxWidth, matchWidthLocally ? margin : measuredWidth);
        } else {
            alternativeMaxWidth = MAX(alternativeMaxWidth, matchWidthLocally ? margin : measuredWidth);
        }
    }
    
    if (self.useLargestChild &&
        (heightMode == AT_MOST || heightMode == UNSPECIFIED)) {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
            
            if (child == nil) {
                continue;
            }
            
            if (child.layoutParams.visible == GONE) {
                continue;
            }
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            // Account for negative margins
            float totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + largestChildHeight + lp.topMargin + lp.bottomMargin);
        }
    }
    
    // Add in our padding
    _totalLength += self.paddingTop + self.paddingBottom;
    
    float heightSize = _totalLength;
    
    // Check against our minimum height
    heightSize = MAX(heightSize, [self.attachView.layoutParams getSuggestedMinimumHeight]);
    
    // Reconcile our calculated size with the heightMeasureSpec
    MeasuredDimension heightSizeAndState = [LayoutContainer resolveSizeAndState:heightSize measureSpec:heightMeasureSpec childMeasuredState:0];
    heightSize = heightSizeAndState.size;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds
    float delta = heightSize - _totalLength;
    if (delta != 0 && totalWeight > 0.0f) {
        float weightSum = self.weightSum> 0.0f ? self.weightSum : totalWeight;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
            
            if (child.layoutParams.visible == GONE) {
                continue;
            }
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            float childExtra = lp.weight;
            if (childExtra > 0) {
                // Child said it could absorb extra space -- give him his share
                float share = (float) (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                MeasureSpec childWidthMeasureSpec = [self getChildMeasureSpec:widthMeasureSpec padding: self.paddingLeft + self.paddingRight + lp.leftMargin + lp.rightMargin childDimension:lp.width];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if ((lp.height != 0) || (heightMode != EXACTLY)) {
                    // child was measured once already above...
                    // base new measurement on stored values
                    float childHeight = [lp getMeasuredHeight] + share;
                    if (childHeight < 0) {
                        childHeight = 0;
                    }
                    
                    MeasureSpec heightSpec;
                    heightSpec.size = childHeight;
                    heightSpec.mode = EXACTLY;
                    [child measure:childWidthMeasureSpec heightMeasureSpec:heightSpec];
                } else {
                    // child was skipped in the loop above.
                    // Measure for this first time here
                    MeasureSpec heightSpec;
                    heightSpec.size = (share > 0 ? share : 0);
                    heightSpec.mode = EXACTLY;
                    
                    [child measure:childWidthMeasureSpec heightMeasureSpec:heightSpec];
                }
                
                // Child may now not fit in vertical dimension.
                childState = [LayoutContainer combineMeasuredStates:childState newState:([lp getMeasuredState] & (MEASURED_STATE_MASK>>MEASURED_HEIGHT_STATE_SHIFT))];
            }
            
            float margin =  lp.leftMargin + lp.rightMargin;
            float measuredWidth = [lp getMeasuredWidth] + margin;
            maxWidth = MAX(maxWidth, measuredWidth);
            
            BOOL matchWidthLocally = widthMode != EXACTLY && lp.width == MATCH_PARENT;
            
            alternativeMaxWidth = MAX(alternativeMaxWidth, matchWidthLocally ? margin : measuredWidth);
            
            allFillParent = allFillParent && lp.width == MATCH_PARENT;
            
            float totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + [lp getMeasuredHeight] + lp.topMargin + lp.bottomMargin);
        }
        
        // Add in our padding
        _totalLength += self.paddingTop + self.paddingBottom;
        // TODO: Should we recompute the heightSpec based on the new total length?
    } else {
        alternativeMaxWidth = MAX(alternativeMaxWidth, weightedMaxWidth);
        
        // We have no limit, so make all weighted views as tall as the largest child.
        // Children will have already been measured once.
        if (self.useLargestChild && widthMode == UNSPECIFIED) {
            for (int i = 0; i < count; i++) {
                UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
                
                if (child == nil || child.layoutParams.visible == GONE) {
                    continue;
                }
                
                LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
                
                float childExtra = lp.weight;
                if (childExtra > 0) {
                    MeasureSpec widthSpec;
                    widthSpec.size = [lp getMeasuredWidth];
                    widthSpec.mode = EXACTLY;
                    
                    MeasureSpec heightSpec;
                    heightSpec.size = largestChildHeight;
                    heightSpec.mode = EXACTLY;
                    
                    [child measure:widthSpec heightMeasureSpec:heightSpec];
                }
            }
        }
    }
    
    if (!allFillParent && widthMode != EXACTLY) {
        maxWidth = alternativeMaxWidth;
    }
    
    maxWidth += self.paddingLeft + self.paddingRight;
    
    // Check against our minimum width
    maxWidth = MAX(maxWidth, [self.attachView.layoutParams getSuggestedMinimumWidth]);
    
    [self.attachView.layoutParams setMeasuredDimension:[LayoutContainer resolveSizeAndState:maxWidth measureSpec:widthMeasureSpec childMeasuredState:childState] height:heightSizeAndState];
    
    if (matchWidth) {
        [self forceUniformWidth:count widthMeasureSpec:heightMeasureSpec];
    }
}

- (void) measureHorizontal:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    _totalLength = 0;
    float maxHeight = 0;
    int childState = 0;
    float alternativeMaxHeight = 0;
    float weightedMaxHeight = 0;
    BOOL allFillParent = YES;
    float totalWeight = 0;
    
    NSUInteger count = [self.attachView.subviews count];
    
    int widthMode = widthMeasureSpec.mode;
    int heightMode = heightMeasureSpec.mode;
    
    BOOL matchHeight = NO;
    
    _maxAscent[0] = _maxAscent[1] = _maxAscent[2] = _maxAscent[3] = -1;
    _maxDescent[0] = _maxDescent[1] = _maxDescent[2] = _maxDescent[3] = -1;
    
    BOOL isExactly = (widthMode == EXACTLY);
    
    float largestChildWidth = FLT_MIN;
    
    // See how wide everyone is. Also remember max height.
    for (int i = 0; i < count; ++i) {
        UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
        
        if (child == nil) {
            continue;
        }
        
        if (child.layoutParams.visible == GONE) {
            continue;
        }
        
        LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
        
        totalWeight += lp.weight;
        
        if (widthMode == EXACTLY && lp.width == 0 && lp.weight > 0) {
            // Optimization: don't bother measuring children who are going to use
            // leftover space. These views will get measured again down below if
            // there is any leftover space.
            if (isExactly) {
                _totalLength += lp.leftMargin + lp.rightMargin;
            } else {
                float totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength +
                                   lp.leftMargin + lp.rightMargin);
            }
            
        } else {
            float oldWidth = FLT_MIN;
            
            if (lp.width == 0 && lp.weight > 0) {
                // widthMode is either UNSPECIFIED or AT_MOST, and this
                // child
                // wanted to stretch to fill available space. Translate that to
                // WRAP_CONTENT so that it does not end up with a width of 0
                oldWidth = 0;
                lp.width = WRAP_CONTENT;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self measureChildBeforeLayout:child childIndex:i widthMeasureSpec:widthMeasureSpec totalWidth:(totalWeight == 0 ? _totalLength : 0) heightMeasureSpec:heightMeasureSpec totalHeight:0];
            
            if (oldWidth != FLT_MIN) {
                lp.width = oldWidth;
            }
            
            float childWidth = [lp getMeasuredWidth];
            if (isExactly) {
                _totalLength += childWidth + lp.leftMargin + lp.rightMargin;
            } else {
                float totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + childWidth + lp.leftMargin + lp.rightMargin);
            }
            
            if (self.useLargestChild) {
                largestChildWidth = MAX(childWidth, largestChildWidth);
            }
        }
        
        BOOL matchHeightLocally = NO;
        if (heightMode != EXACTLY && lp.height == MATCH_PARENT) {
            // The height of the linear layout will scale, and at least one
            // child said it wanted to match our height. Set a flag indicating that
            // we need to remeasure at least that view when we know our height.
            matchHeight = YES;
            matchHeightLocally = YES;
        }
        
        float margin = lp.topMargin + lp.bottomMargin;
        float childHeight = [lp getMeasuredHeight] + margin;
        childState = [LayoutContainer combineMeasuredStates:childState newState:[lp getMeasuredState]];
        
        maxHeight = MAX(maxHeight, childHeight);
        
        allFillParent = allFillParent && lp.height == MATCH_PARENT;
        if (lp.weight > 0) {
            /*
             * Heights of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxHeight = MAX(weightedMaxHeight, matchHeightLocally ? margin : childHeight);
        } else {
            alternativeMaxHeight = MAX(alternativeMaxHeight, matchHeightLocally ? margin : childHeight);
        }
    }
    
    // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
    // the most common case
    if (_maxAscent[INDEX_TOP] != -1 ||
        _maxAscent[INDEX_CENTER_VERTICAL] != -1 ||
        _maxAscent[INDEX_BOTTOM] != -1 ||
        _maxAscent[INDEX_FILL] != -1) {
        int ascent = MAX(_maxAscent[INDEX_FILL],
                         MAX(_maxAscent[INDEX_CENTER_VERTICAL],
                             MAX(_maxAscent[INDEX_TOP], _maxAscent[INDEX_BOTTOM])));
        int descent = MAX(_maxDescent[INDEX_FILL],
                          MAX(_maxDescent[INDEX_CENTER_VERTICAL],
                              MAX(_maxDescent[INDEX_TOP], _maxDescent[INDEX_BOTTOM])));
        maxHeight = MAX(maxHeight, ascent + descent);
    }
    
    if (self.useLargestChild && (widthMode == AT_MOST || widthMode == UNSPECIFIED)) {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
            
            if (child == nil) {
                continue;
            }
            
            if (child.layoutParams.visible == GONE) {
                continue;
            }
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            if (isExactly) {
                _totalLength += largestChildWidth + lp.leftMargin + lp.rightMargin;
            } else {
                float totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + largestChildWidth + lp.leftMargin + lp.rightMargin);
            }
        }
    }
    
    // Add in our padding
    _totalLength += self.paddingLeft + self.paddingRight;
    
    float widthSize = _totalLength;
    
    // Check against our minimum width
    widthSize = MAX(widthSize, [self.attachView.layoutParams getSuggestedMinimumWidth]);
    
    // Reconcile our calculated size with the widthMeasureSpec
    MeasuredDimension widthSizeAndState = [LayoutContainer resolveSizeAndState:widthSize measureSpec:widthMeasureSpec childMeasuredState:0];
    widthSize = widthSizeAndState.size;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds
    float delta = widthSize - _totalLength;
    if (delta != 0 && totalWeight > 0.0f) {
        float weightSum = self.weightSum > 0.0f ? self.weightSum : totalWeight;
        
        _maxAscent[0] = _maxAscent[1] = _maxAscent[2] = _maxAscent[3] = -1;
        _maxDescent[0] = _maxDescent[1] = _maxDescent[2] = _maxDescent[3] = -1;
        maxHeight = -1;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
            
            if (child == nil || child.layoutParams.visible == GONE) {
                continue;
            }
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            float childExtra = lp.weight;
            if (childExtra > 0) {
                // Child said it could absorb extra space -- give him his share
                float share = (float) (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                MeasureSpec childHeightMeasureSpec = [self getChildMeasureSpec:heightMeasureSpec padding: self.paddingTop + self.paddingBottom + lp.topMargin + lp.bottomMargin childDimension: lp.height];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if ((lp.width != 0) || (widthMode != EXACTLY)) {
                    // child was measured once already above ... base new measurement
                    // on stored values
                    float childWidth = [lp getMeasuredWidth] + share;
                    if (childWidth < 0) {
                        childWidth = 0;
                    }
                    
                    MeasureSpec widthSpec;
                    widthSpec.size = childWidth;
                    widthSpec.mode = EXACTLY;
                    [child measure:widthSpec heightMeasureSpec:childHeightMeasureSpec];
                } else {
                    // child was skipped in the loop above. Measure for this first time here
                    MeasureSpec widthSpec;
                    widthSpec.size = (share > 0 ? share : 0);
                    widthSpec.mode = EXACTLY;
                    
                    [child measure:widthSpec heightMeasureSpec:childHeightMeasureSpec];
                }
                
                // Child may now not fit in horizontal dimension.
                childState = [LayoutContainer combineMeasuredStates:childState newState:([lp getMeasuredState] & MEASURED_STATE_MASK)];
            }
            
            if (isExactly) {
                _totalLength += [lp getMeasuredWidth] + lp.leftMargin + lp.rightMargin;
            } else {
                float totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + [lp getMeasuredWidth] + lp.leftMargin + lp.rightMargin);
            }
            
            BOOL matchHeightLocally = (heightMode != EXACTLY) && (lp.height == MATCH_PARENT);
            
            float margin = lp.topMargin + lp .bottomMargin;
            float childHeight = [lp getMeasuredHeight] + margin;
            maxHeight = MAX(maxHeight, childHeight);
            alternativeMaxHeight = MAX(alternativeMaxHeight, matchHeightLocally ? margin : childHeight);
            
            allFillParent = allFillParent && lp.height == MATCH_PARENT;
        }
        
        // Add in our padding
        _totalLength += self.paddingLeft + self.paddingRight;
        // TODO: Should we update widthSize with the new total length?
        
        // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
        // the most common case
        if (_maxAscent[INDEX_TOP] != -1 ||
            _maxAscent[INDEX_CENTER_VERTICAL] != -1 ||
            _maxAscent[INDEX_BOTTOM] != -1 ||
            _maxAscent[INDEX_FILL] != -1) {
            int ascent = MAX(_maxAscent[INDEX_FILL], MAX(_maxAscent[INDEX_CENTER_VERTICAL], MAX(_maxAscent[INDEX_TOP], _maxAscent[INDEX_BOTTOM])));
            int descent = MAX(_maxDescent[INDEX_FILL], MAX(_maxDescent[INDEX_CENTER_VERTICAL], MAX(_maxDescent[INDEX_TOP], _maxDescent[INDEX_BOTTOM])));
            maxHeight = MAX(maxHeight, ascent + descent);
        }
    } else {
        alternativeMaxHeight = MAX(alternativeMaxHeight, weightedMaxHeight);
        
        // We have no limit, so make all weighted views as wide as the largest child.
        // Children will have already been measured once.
        if (self.useLargestChild && widthMode == UNSPECIFIED) {
            for (int i = 0; i < count; i++) {
                UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
                
                if (child == nil || child.layoutParams.visible == GONE) {
                    continue;
                }
                
                LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
                
                float childExtra = lp.weight;
                if (childExtra > 0) {
                    MeasureSpec widthSpec;
                    widthSpec.size = largestChildWidth;
                    widthSpec.mode = EXACTLY;
                    
                    MeasureSpec heightSpec;
                    heightSpec.size = [lp getMeasuredHeight];
                    heightSpec.mode = EXACTLY;
                    
                    [child measure:widthSpec heightMeasureSpec:heightSpec];
                }
            }
        }
    }
    
    if (!allFillParent && heightMode != EXACTLY) {
        maxHeight = alternativeMaxHeight;
    }
    
    maxHeight += self.paddingTop + self.paddingBottom;
    
    // Check against our minimum height
    maxHeight = MAX(maxHeight, [self.attachView.layoutParams getSuggestedMinimumHeight]);
    
    widthSizeAndState.state = widthSizeAndState.state | (childState & MEASURED_STATE_MASK);
    [self.attachView.layoutParams setMeasuredDimension:widthSizeAndState height:[LayoutContainer resolveSizeAndState:maxHeight measureSpec:heightMeasureSpec childMeasuredState:(childState<<MEASURED_HEIGHT_STATE_SHIFT)]];
    
    if (matchHeight) {
        [self forceUniformHeight:count widthMeasureSpec:widthMeasureSpec];
    }
}

#pragma mark - layout
- (void) onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
    if (self.orientation == VERTICAL) {
        [self layoutVertical];
    }
    else {
        [self layoutHorizontal];
    }
}

- (void) layoutVertical
{
    float paddingLeft = self.paddingLeft;
    
    float childTop;
    float childLeft;
    
    // Where right end of child should go
    float width = self.attachView.width;
    float childRight = width - self.paddingRight;
    
    // Space available for child
    float childSpace = width - paddingLeft - self.paddingRight;
    
    NSUInteger count = [self.attachView.subviews count];
    
    if (self.gravity & GRAVITY_BOTTOM) {
        childTop = self.paddingTop + self.attachView.height - _totalLength;
    }
    else if (self.gravity & GRAVITY_CENTER_VERTICAL) {
        childTop = self.paddingTop + (self.attachView.height - _totalLength) / 2;
    }
    else {
        childTop = self.paddingTop;
    }
    
    for (int i = 0; i < count; i++) {
        UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
        if (child == nil) {
        } else if (child.layoutParams.visible != GONE) {
            float childWidth = [child.layoutParams getMeasuredWidth];
            float childHeight = [child.layoutParams getMeasuredHeight];
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            int gravity = lp.gravity;
            if (gravity < 0) {
                gravity = self.gravity;
            }
            
            if (gravity & GRAVITY_RIGHT) {
                childLeft = childRight - childWidth - lp.rightMargin;
            }
            else if (gravity & GRAVITY_CENTER_HORIZONTAL) {
                childLeft = paddingLeft + ((childSpace - childWidth) / 2) + lp.leftMargin - lp.rightMargin;
            }
            else {
                childLeft = paddingLeft + lp.leftMargin;
            }
            
            childTop += lp.topMargin;
            
            [self setChildFrame:child left:childLeft top:childTop width:childWidth height:childHeight];
            childTop += childHeight + lp.bottomMargin;
        }
    }
}

- (void) layoutHorizontal
{
    float paddingTop = self.paddingTop;
    
    float childTop;
    float childLeft;
    
    // Where bottom of child should go
    float height = self.attachView.height;
    float childBottom = height - self.paddingBottom;
    
    // Space available for child
    float childSpace = height - paddingTop - self.paddingBottom;
    
    NSUInteger count = [self.attachView.subviews count];
    
    if (self.gravity & GRAVITY_RIGHT) {
        childLeft = self.paddingLeft + self.attachView.width - _totalLength;
    }
    else if (self.gravity & GRAVITY_CENTER_HORIZONTAL) {
        childLeft = self.paddingLeft + (self.attachView.width - _totalLength) / 2;
    }
    else {
        childLeft = self.paddingLeft;
    }
    
    for (int i = 0; i < count; i++) {
        UIView* child = (UIView*)[self.attachView.subviews objectAtIndex:i];
        if (child == nil) {
            
        }
        else if (child.layoutParams.visible != GONE) {
            float childWidth = [child.layoutParams getMeasuredWidth];
            float childHeight = [child.layoutParams getMeasuredHeight];
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            int gravity = lp.gravity;
            if (gravity < 0) {
                gravity = self.gravity;
            }
            
            if (gravity & GRAVITY_BOTTOM) {
                childTop = childBottom - childHeight - lp.bottomMargin;
            }
            else if (gravity & GRAVITY_CENTER_VERTICAL) {
                childTop = paddingTop + ((childSpace - childHeight) / 2) + lp.topMargin - lp.bottomMargin;
            }
            else if (gravity & GRAVITY_TOP) {
                childTop = paddingTop + lp.topMargin;
            }
            else {
                childTop = self.paddingTop;
            }
            
            childLeft += lp.leftMargin;
            [self setChildFrame:child left:childLeft top:childTop width:childWidth height:childHeight];
            childLeft += childWidth + lp.rightMargin;
        }
    }
}

- (void) forceUniformWidth:(NSUInteger)count widthMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    // Pretend that the linear layout has an exact size.
    MeasureSpec uniformMeasureSpec;
    uniformMeasureSpec.size = [self.attachView.layoutParams getMeasuredWidth];
    uniformMeasureSpec.mode = EXACTLY;
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            if (lp.width == MATCH_PARENT) {
                // Temporarily force children to reuse their old measured height
                // FIXME: this may not be right for something like wrapping text?
                float oldHeight = lp.height;
                lp.height = [lp getMeasuredHeight];
                
                // Remeasue with new dimensions
                [self measureChildWithMargins:child parentWidthMeasureSpec:uniformMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
                lp.height = oldHeight;
            }
        }
    }
}

- (void) forceUniformHeight:(NSUInteger)count widthMeasureSpec:(MeasureSpec)widthMeasureSpec
{
    // Pretend that the linear layout has an exact size. This is the measured height of
    // ourselves. The measured height should be the max height of the children, changed
    // to accomodate the heightMesureSpec from the parent
    MeasureSpec uniformMeasureSpec;
    uniformMeasureSpec.size = [self.attachView.layoutParams getMeasuredHeight];
    uniformMeasureSpec.mode = EXACTLY;
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            if (lp.height == MATCH_PARENT) {
                // Temporarily force children to reuse their old measured width
                // FIXME: this may not be right for something like wrapping text?
                float oldWidth = lp.width;
                lp.width = [lp getMeasuredWidth];
                
                // Remeasure with new dimensions
                [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:uniformMeasureSpec heightUsed:0];
                lp.width = oldWidth;
            }
        }
    }
}

- (void) measureChildBeforeLayout:(UIView*)child childIndex:(int)childIndex widthMeasureSpec:(MeasureSpec)widthMeasureSpec totalWidth:(float)totalWidth heightMeasureSpec:(MeasureSpec)heightMeasureSpec totalHeight:(float)totalHeight
{
    [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:totalWidth parentHeightMeasureSpec:heightMeasureSpec heightUsed:totalHeight];
}

- (void) setChildFrame:(UIView*)child left:(float)left top:(float)top width:(float)width height:(float)height
{
    [child layout:left top:top right:left + width bottom:top + height];
}

- (MarginLayoutParams*)makeChildLayoutParams
{
    return [[LinearLayoutParams alloc] init];
}

@end
