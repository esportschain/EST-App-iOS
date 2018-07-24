//
//  RelativeLayout.m
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

#import "RelativeLayout.h"
#import "UIView+Layout.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface RelativeLayoutParams()
@property(nonatomic, assign) float left;
@property(nonatomic, assign) float top;
@property(nonatomic, assign) float right;
@property(nonatomic, assign) float bottom;
@end

/**
 * RelativeLayoutParams
 */
@implementation RelativeLayoutParams

@end

/**
 * RelativeLayout
 */
@implementation RelativeLayout

+(RelativeLayout*) layout
{
    RelativeLayout* instance = [[RelativeLayout alloc] init];
    if (instance) {
        
    }
    
    return instance;
}

- (void) onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    float myWidth = -1;
    float myHeight = -1;
    
    float width = 0;
    float height = 0;
    
    int widthMode = widthMeasureSpec.mode;
    int heightMode = heightMeasureSpec.mode;
    float widthSize = widthMeasureSpec.size;
    float heightSize = heightMeasureSpec.size;
    
    // Record our dimensions if they are known;
    if (widthMode != UNSPECIFIED) {
        myWidth = widthSize;
    }
    
    if (heightMode != UNSPECIFIED) {
        myHeight = heightSize;
    }
    
    if (widthMode == EXACTLY) {
        width = myWidth;
    }
    
    if (heightMode == EXACTLY) {
        height = myHeight;
    }
    
    float left = FLT_MAX;
    float top = FLT_MAX;
    float right = FLT_MIN;
    float bottom = FLT_MIN;
    
    BOOL offsetHorizontalAxis = NO;
    BOOL offsetVerticalAxis = NO;
    
    BOOL isWrapContentWidth = widthMode != EXACTLY;
    BOOL isWrapContentHeight = heightMode != EXACTLY;
    
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*) child.layoutParams;
            
            [self applyHorizontalSizeRules:params myWidth:myWidth];
            [self measureChildHorizontal:child params:params myWidth:myWidth myHeight:myHeight];
            if ([self positionChildHorizontal:child params:params myWidth:myWidth wrapContent:isWrapContentWidth]) {
                offsetHorizontalAxis = YES;
            }
        }
    }
    
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*) child.layoutParams;
            
            [self applyVerticalSizeRules:params myHeight:myHeight];
            [self measureChild:child params:params myWidth:myWidth myHeight:myHeight];
            if ([self positionChildVertical:child params:params myHeight:myHeight wrapContent:isWrapContentHeight]) {
                offsetVerticalAxis = true;
            }
            
            if (isWrapContentWidth) {
                width = MAX(width, params.right + params.rightMargin);
            }
            
            if (isWrapContentHeight) {
                height = MAX(height, params.bottom + params.bottomMargin);
            }
            
            //            if (child != ignore || verticalGravity) {
            left = MIN(left, params.left - params.leftMargin);
            top = MIN(top, params.top - params.topMargin);
            //            }
            
            //            if (child != ignore || horizontalGravity) {
            right = MAX(right, params.right + params.rightMargin);
            bottom = MAX(bottom, params.bottom + params.bottomMargin);
            //            }
        }
    }
    
    if (isWrapContentWidth) {
        // Width already has left padding in it since it was calculated by looking at
        // the right of each child view
        width += self.paddingRight;
        
        if (self.attachView.layoutParams.width >= 0) {
            width = MAX(width, self.attachView.layoutParams.width);
        }
        
        width = MAX(width, [self.attachView.layoutParams getSuggestedMinimumWidth]);
        width = [LayoutContainer resolveSize:width measureSpec:widthMeasureSpec];
        
        if (offsetHorizontalAxis) {
            for (UIView* child in self.attachView.subviews) {
                if (child.layoutParams.visible != GONE) {
                    RelativeLayoutParams* params = (RelativeLayoutParams*) child.layoutParams;
                    if (params.centerHorizontal) {
                        [self centerHorizontal:child params:params myWidth:width];
                    } else if (params.alignParentRight) {
                        float childWidth = [child.layoutParams getMeasuredWidth];
                        params.left = width - self.paddingRight - childWidth;
                        params.right = params.left + childWidth;
                    }
                }
            }
        }
    }
    
    if (isWrapContentHeight) {
        // Height already has top padding in it since it was calculated by looking at
        // the bottom of each child view
        height += self.paddingBottom;
        
        if (self.attachView.layoutParams.height >= 0) {
            height = MAX(height, self.attachView.layoutParams.height);
        }
        
        height = MAX(height, [self.attachView.layoutParams getSuggestedMinimumHeight]);
        height = [LayoutContainer resolveSize:height measureSpec:heightMeasureSpec];
        
        if (offsetVerticalAxis) {
            for (UIView* child in self.attachView.subviews) {
                if (child.layoutParams.visible != GONE) {
                    RelativeLayoutParams* params = (RelativeLayoutParams*) child.layoutParams;
                    if (params.centerVertical) {
                        [self centerVertical:child params:params myHeight:height];
                    } else if (params.alignParentBottom) {
                        float childHeight = [child.layoutParams getMeasuredHeight];
                        params.top = height - self.paddingBottom - childHeight;
                        params.bottom = params.top + childHeight;
                    }
                }
            }
        }
    }
    
    //    if (horizontalGravity || verticalGravity) {
    //        final Rect selfBounds = mSelfBounds;
    //        selfBounds.set(mPaddingLeft, mPaddingTop, width - mPaddingRight,
    //                       height - mPaddingBottom);
    //
    //        final Rect contentBounds = mContentBounds;
    //        final int layoutDirection = getResolvedLayoutDirection();
    //        Gravity.apply(mGravity, right - left, bottom - top, selfBounds, contentBounds,
    //                      layoutDirection);
    //
    //        final int horizontalOffset = contentBounds.left - left;
    //        final int verticalOffset = contentBounds.top - top;
    //        if (horizontalOffset != 0 || verticalOffset != 0) {
    //            for (int i = 0; i < count; i++) {
    //                View child = getChildAt(i);
    //                if (child.getVisibility() != GONE && child != ignore) {
    //                    LayoutParams params = (LayoutParams) child.getLayoutParams();
    //                    if (horizontalGravity) {
    //                        params.mLeft += horizontalOffset;
    //                        params.mRight += horizontalOffset;
    //                    }
    //                    if (verticalGravity) {
    //                        params.mTop += verticalOffset;
    //                        params.mBottom += verticalOffset;
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    MeasuredDimension widthDimension;
    widthDimension.state = 0;
    widthDimension.size = width;
    
    MeasuredDimension heightDimension;
    heightDimension.state = 0;
    heightDimension.size = height;
    [self.attachView.layoutParams setMeasuredDimension:widthDimension height:heightDimension];
}

#pragma mark - layout
- (void) onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
    for (UIView* child in self.attachView.subviews) {
        if (child.layoutParams.visible != GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*) child.layoutParams;
            [child layout:params.left top:params.top right:params.right bottom:params.bottom];
        }
    }
}

#pragma mark - private
- (void) applyHorizontalSizeRules:(RelativeLayoutParams*)childParams myWidth:(float)myWidth
{
    RelativeLayoutParams* anchorParams = nil;
    
    // -1 indicated a "soft requirement" in that direction. For example:
    // left=10, right=-1 means the view must start at 10, but can go as far as it wants to the right
    // left =-1, right=10 means the view must end at 10, but can go as far as it wants to the left
    // left=10, right=20 means the left and right ends are both fixed
    childParams.left = -1;
    childParams.right = -1;
    
    // get archor params
    anchorParams = nil;
    if (childParams.leftOf) {
        UIView* anchorView = childParams.leftOf;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.leftOf;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.right = anchorParams.left - (anchorParams.leftMargin +
                                                 childParams.rightMargin);
    } else if (childParams.alignWithParent && childParams.leftOf) {
        if (myWidth >= 0) {
            childParams.right = myWidth - self.paddingRight - childParams.rightMargin;
        }
    }
    
    // get archor params
    anchorParams = nil;
    if (childParams.rightOf) {
        UIView* anchorView = childParams.rightOf;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.rightOf;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.left = anchorParams.right + (anchorParams.rightMargin +
                                                 childParams.leftMargin);
    } else if (childParams.alignWithParent && childParams.rightOf) {
        childParams.left = self.paddingLeft + childParams.leftMargin;
    }
    
    // get archor params
    anchorParams = nil;
    if (childParams.alignLeft) {
        UIView* anchorView = childParams.alignLeft;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.alignLeft;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.left = anchorParams.left + childParams.leftMargin;
    } else if (childParams.alignWithParent && childParams.alignLeft) {
        childParams.left = self.paddingLeft + childParams.leftMargin;
    }
    
    // get archor params
    anchorParams = nil;
    if (childParams.alignRight) {
        UIView* anchorView = childParams.alignRight;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.alignRight;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.right = anchorParams.right - childParams.rightMargin;
    } else if (childParams.alignWithParent && childParams.alignRight) {
        if (myWidth >= 0) {
            childParams.right = myWidth - self.paddingRight - childParams.rightMargin;
        }
    }
    
    if (childParams.alignParentLeft) {
        childParams.left = self.paddingLeft + childParams.leftMargin;
    }
    
    if (childParams.alignParentRight) {
        if (myWidth >= 0) {
            childParams.right = myWidth - self.paddingRight - childParams.rightMargin;
        }
    }
}

- (void) applyVerticalSizeRules:(RelativeLayoutParams*)childParams myHeight:(float)myHeight
{
    RelativeLayoutParams* anchorParams = nil;
    
    childParams.top = -1;
    childParams.bottom = -1;
    
    // get archor params
    anchorParams = nil;
    if (childParams.aboveOf) {
        UIView* anchorView = childParams.aboveOf;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.aboveOf;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.bottom = anchorParams.top - (anchorParams.topMargin +
                                                 childParams.bottomMargin);
    } else if (childParams.alignWithParent && childParams.aboveOf) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - self.paddingBottom - childParams.bottomMargin;
        }
    }
    
    // get archor params
    anchorParams = nil;
    if (childParams.belowOf) {
        UIView* anchorView = childParams.belowOf;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.belowOf;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.top = anchorParams.bottom + (anchorParams.bottomMargin +
                                                 childParams.topMargin);
    } else if (childParams.alignWithParent && childParams.belowOf) {
        childParams.top = self.paddingTop + childParams.topMargin;
    }
    
    // get archor params
    anchorParams = nil;
    if (childParams.alignTop) {
        UIView* anchorView = childParams.alignTop;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.alignTop;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.top = anchorParams.top + childParams.topMargin;
    } else if (childParams.alignWithParent && childParams.alignTop) {
        childParams.top = self.paddingTop + childParams.topMargin;
    }
    
    // get archor params
    anchorParams = nil;
    if (childParams.alignBottom) {
        UIView* anchorView = childParams.alignBottom;
        while (anchorView.layoutParams.visible == GONE) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)anchorView.layoutParams;
            anchorView = params.alignBottom;
            if (anchorView == nil) {
                break;
            }
        }
        if (anchorView) {
            anchorParams = (RelativeLayoutParams*)anchorView.layoutParams;
        }
    }
    if (anchorParams != nil) {
        childParams.bottom = anchorParams.bottom - childParams.bottomMargin;
    } else if (childParams.alignWithParent && childParams.alignBottom) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - self.paddingBottom - childParams.bottomMargin;
        }
    }
    
    if (childParams.alignParentTop) {
        childParams.top = self.paddingTop + childParams.topMargin;
    }
    
    if (childParams.alignParentBottom) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - self.paddingBottom - childParams.bottomMargin;
        }
    }
}

- (void) measureChild:(UIView*)child params:(RelativeLayoutParams*)params myWidth:(float)myWidth myHeight:(float)myHeight
{
    MeasureSpec childWidthMeasureSpec = [self getChildMeasureSpec:params.left
                                                 childEnd:params.right
                                                childSize:params.width
                                              startMargin:params.leftMargin
                                                endMargin:params.rightMargin
                                             startPadding:self.paddingLeft
                                               endPadding:self.paddingRight
                                                   mySize:myWidth];
    
    MeasureSpec childHeightMeasureSpec = [self getChildMeasureSpec:params.top
                                                  childEnd:params.bottom
                                                 childSize:params.height
                                               startMargin:params.topMargin
                                                 endMargin:params.bottomMargin
                                              startPadding:self.paddingTop
                                                endPadding:self.paddingBottom
                                                    mySize:myHeight];
    
    [child measure:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void) measureChildHorizontal:(UIView*)child params:(RelativeLayoutParams*)params myWidth:(float)myWidth myHeight:(float)myHeight
{
    MeasureSpec childWidthMeasureSpec = [self getChildMeasureSpec:params.left
                                                 childEnd:params.right
                                                childSize:params.width
                                              startMargin:params.leftMargin
                                                endMargin:params.rightMargin
                                             startPadding:self.paddingLeft
                                               endPadding:self.paddingRight
                                                   mySize:myWidth];
    MeasureSpec childHeightMeasureSpec;
    if (params.width == MATCH_PARENT) {
        childHeightMeasureSpec.size = myHeight;
        childHeightMeasureSpec.mode = EXACTLY;
    } else {
        childHeightMeasureSpec.size = myHeight;
        childHeightMeasureSpec.mode = AT_MOST;
    }
    
    [child measure:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (MeasureSpec)getChildMeasureSpec:(float)childStart
                  childEnd:(float)childEnd
                 childSize:(float)childSize
               startMargin:(float)startMargin
                 endMargin:(float)endMargin
              startPadding:(float)startPadding
                endPadding:(float)endPadding
                    mySize:(float)mySize
{
    int childSpecMode = 0;
    float childSpecSize = 0;
    
    // Figure out start and end bounds.
    float tempStart = childStart;
    float tempEnd = childEnd;
    
    // If the view did not express a layout constraint for an edge, use
    // view's margins and our padding
    if (tempStart < 0) {
        tempStart = startPadding + startMargin;
    }
    if (tempEnd < 0) {
        tempEnd = mySize - endPadding - endMargin;
    }
    
    // Figure out maximum size available to this view
    float maxAvailable = tempEnd - tempStart;
    
    if (childStart >= 0 && childEnd >= 0) {
        // Constraints fixed both edges, so child must be an exact size
        childSpecMode = EXACTLY;
        childSpecSize = maxAvailable;
    } else {
        if (childSize >= 0) {
            // Child wanted an exact size. Give as much as possible
            childSpecMode = EXACTLY;
            
            if (maxAvailable >= 0) {
                // We have a maxmum size in this dimension.
                childSpecSize = MIN(maxAvailable, childSize);
            } else {
                // We can grow in this dimension.
                childSpecSize = childSize;
            }
        } else if (childSize == MATCH_PARENT) {
            // Child wanted to be as big as possible. Give all availble
            // space
            childSpecMode = EXACTLY;
            childSpecSize = maxAvailable;
        } else if (childSize == WRAP_CONTENT) {
            // Child wants to wrap content. Use AT_MOST
            // to communicate available space if we know
            // our max size
            if (self.limitChild) {
                if (maxAvailable >= 0) {
                    // We have a maxmum size in this dimension.
                    childSpecMode = AT_MOST;
                    childSpecSize = maxAvailable;
                } else {
                    // We can grow in this dimension. Child can be as big as it
                    // wants
                    childSpecMode = UNSPECIFIED;
                    childSpecSize = 0;
                }
            }
            else {
                // We can grow in this dimension. Child can be as big as it
                // wants
                childSpecMode = UNSPECIFIED;
                childSpecSize = 0;
            }
        }
    }
    
    MeasureSpec measureSpec;
    measureSpec.size = childSpecSize;
    measureSpec.mode = childSpecMode;
    return measureSpec;
}

- (BOOL) positionChildHorizontal:(UIView*)child params:(RelativeLayoutParams*)params myWidth:(float)myWidth wrapContent:(BOOL)wrapContent
{
    if (params.left < 0 && params.right >= 0) {
        // Right is fixed, but left varies
        params.left = params.right - [child.layoutParams getMeasuredWidth];
    } else if (params.left >= 0 && params.right < 0) {
        // Left is fixed, but right varies
        params.right = params.left + [child.layoutParams getMeasuredWidth];
    } else if (params.left < 0 && params.right < 0) {
        // Both left and right vary
        if (params.centerHorizontal) {
            if (!wrapContent) {
                [self centerHorizontal:child params:params myWidth:myWidth];
            } else {
                params.left = self.paddingLeft + params.leftMargin;
                params.right = params.left + [child.layoutParams getMeasuredWidth];
            }
            
            return YES;
        } else {
            params.left = self.paddingLeft + params.leftMargin;
            params.right = params.left + [child.layoutParams getMeasuredWidth];
        }
    }
    
    return params.alignParentRight;
}

- (BOOL) positionChildVertical:(UIView*)child params:(RelativeLayoutParams*)params myHeight:(float)myHeight wrapContent:(BOOL)wrapContent
{
    if (params.top < 0 && params.bottom >= 0) {
        // Bottom is fixed, but top varies
        params.top = params.bottom - [child.layoutParams getMeasuredHeight];
    } else if (params.top >= 0 && params.bottom < 0) {
        // Top is fixed, but bottom varies
        params.bottom = params.top + [child.layoutParams getMeasuredHeight];
    } else if (params.top < 0 && params.bottom < 0) {
        // Both top and bottom vary
        if (params.centerVertical) {
            if (!wrapContent) {
                [self centerVertical:child params:params myHeight:myHeight];
            } else {
                params.top = self.paddingTop + params.topMargin;
                params.bottom = params.top + [child.layoutParams getMeasuredHeight];
            }
            
            return YES;
        } else {
            params.top = self.paddingTop + params.topMargin;
            params.bottom = params.top + [child.layoutParams getMeasuredHeight];
        }
    }
    
    return params.alignParentBottom;
}

- (void) centerHorizontal:(UIView*)child params:(RelativeLayoutParams*)params myWidth:(float)myWidth
{
    float childWidth = [child.layoutParams getMeasuredWidth];
    float left = (myWidth - childWidth) / 2;
    
    params.left = left;
    params.right = left + childWidth;
}

- (void) centerVertical:(UIView*)child params:(RelativeLayoutParams*)params myHeight:(float)myHeight
{
    float childHeight = [child.layoutParams getMeasuredHeight];
    float top = (myHeight - childHeight) / 2;
    
    params.top = top;
    params.bottom = top + childHeight;
}

- (MarginLayoutParams*)makeChildLayoutParams
{
    return [[RelativeLayoutParams alloc] init];
}

- (void) onRemoveSubview:(UIView*)subView
{
    if (subView) {
        for (UIView* child in self.attachView.subviews) {
            RelativeLayoutParams* params = (RelativeLayoutParams*)child.layoutParams;
            if ([params.leftOf isEqual:subView]) {
                params.leftOf = nil;
            }
            if ([params.rightOf isEqual:subView]) {
                params.rightOf = nil;
            }
            if ([params.aboveOf isEqual:subView]) {
                params.aboveOf = nil;
            }
            if ([params.belowOf isEqual:subView]) {
                params.belowOf = nil;
            }
            if ([params.alignLeft isEqual:subView]) {
                params.alignLeft = nil;
            }
            if ([params.alignRight isEqual:subView]) {
                params.alignRight = nil;
            }
            if ([params.alignTop isEqual:subView]) {
                params.alignTop = nil;
            }
            if ([params.alignBottom isEqual:subView]) {
                params.alignBottom = nil;
            }
        }
    }
    
    [super onRemoveSubview:subView];
}

@end

