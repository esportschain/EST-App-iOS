//
//  UIView+Layout.m
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

#import "UIView+Layout.h"
#import <objc/runtime.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

/**
 * 支持类似于Android的布局方式
 */
@implementation UIView (Layout)
@dynamic layoutContainer;
@dynamic layoutParams;
@dynamic layoutDelegate;
@dynamic userInfo;

// 扩展属性
-(void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

-(CGFloat)x
{
    return self.frame.origin.x;
}

-(void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

-(CGFloat)y
{
    return self.frame.origin.y;
}

-(void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

-(CGFloat)width
{
    return self.frame.size.width;
}

-(void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

-(CGFloat)height
{
    return self.frame.size.height;
}

- (void)setRight:(CGFloat)right
{
    self.x = right - self.width;
}

- (CGFloat)right
{
    return self.x + self.width;
}

- (void)setBottom:(CGFloat)bottom
{
    self.y = bottom - self.height;
}

- (CGFloat)bottom
{
    return self.y + self.height;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint) origin
{
    return self.frame.origin;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void) setLayoutParams:(MarginLayoutParams *)layoutParams
{
    objc_setAssociatedObject(self, @selector(layoutParams), layoutParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MarginLayoutParams*)layoutParams
{
    return objc_getAssociatedObject(self, @selector(layoutParams));
}

- (void) setLayoutContainer:(LayoutContainer *)layoutContainer
{
    objc_setAssociatedObject(self, @selector(layoutContainer), layoutContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LayoutContainer*)layoutContainer
{
    return objc_getAssociatedObject(self, @selector(layoutContainer));
}

- (void) setLayoutDelegate:(id<onLayoutDelegate>)layoutDelegate
{
    objc_setAssociatedObject(self, @selector(layoutDelegate), layoutDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<onLayoutDelegate>) layoutDelegate
{
    return objc_getAssociatedObject(self, @selector(layoutDelegate));
}

- (void) setUserInfo:(NSObject *)userInfo
{
    objc_setAssociatedObject(self, @selector(userInfo), userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject*) userInfo
{
    return objc_getAssociatedObject(self, @selector(userInfo));
}

// 做为容器初始化
+ (id) build:(UIView*)parent container:(LayoutContainer*)container config:(LayoutContainerConfig)config
{
    UIView* instance = (UIView*)[[[self class] alloc] initWithFrame:CGRectZero];
    if (instance) {
        [parent addSubview:instance];
        
        if (parent.layoutContainer) {
            instance.layoutParams = [parent.layoutContainer makeChildLayoutParams];
        }
        else {
            instance.layoutParams = [[MarginLayoutParams alloc] init];
        }
        
        instance.layoutParams.attachView = instance;
        container.attachView = instance;
        instance.layoutContainer = container;
        
        if (config) {
            config(container, instance.layoutParams, instance);
        }
    }
    
    return instance;
}

// 做为控件初始化
+ (id) build:(UIView*)parent config:(LayoutConfig)config
{
    UIView* instance = (UIView*)[[[self class] alloc] initWithFrame:CGRectZero];
    if (instance) {
        [parent addSubview:instance];
        
        if (parent.layoutContainer) {
            instance.layoutParams = [parent.layoutContainer makeChildLayoutParams];
        }
        else {
            instance.layoutParams = [[MarginLayoutParams alloc] init];
        }
        
        instance.layoutParams.attachView = instance;
        
        if (config) {
            config(instance.layoutParams, instance);
        }
    }
    
    return instance;
}

// 扩展UIView的功能，增加删除子View的功能
- (void) removeSubviewAtIndex:(NSInteger)index
{
    if (index >=0 && index < [self.subviews count]) {
        UIView *subview = [self.subviews objectAtIndex:index];
        [self removeSubview:subview];
    }
}

- (void) removeSubview:(UIView*)subView
{
    if (subView) {
        [subView removeFromSuperview];
        
        if (self.layoutContainer) {
            [self.layoutContainer onRemoveSubview:subView];
        }
    }
}

// 更新子控件的布局
- (void) requestLayout
{
    if (self.layoutContainer) {
        if (!self.superview.layoutContainer) {
            MeasureSpec widthMeasureSpec;
            MeasureSpec heightMeasureSpec;
            if (self.layoutParams.width >= 0) {
                widthMeasureSpec = [LayoutContainer getRootMeasureSpec:self.layoutParams.width rootDimension:self.layoutParams.width];
            }
            else if (self.layoutParams.width == WRAP_CONTENT) {
                widthMeasureSpec = [LayoutContainer getRootMeasureSpec:self.superview.frame.size.width - self.layoutParams.leftMargin - self.layoutParams.rightMargin rootDimension:WRAP_CONTENT];
            }
            else {
                widthMeasureSpec = [LayoutContainer getRootMeasureSpec:self.superview.frame.size.width - self.layoutParams.leftMargin - self.layoutParams.rightMargin rootDimension:MATCH_PARENT];
            }
            
            if (self.layoutParams.height >= 0) {
                heightMeasureSpec = [LayoutContainer getRootMeasureSpec:self.layoutParams.height rootDimension:self.layoutParams.height];
            }
            else if (self.layoutParams.height == WRAP_CONTENT) {
                heightMeasureSpec = [LayoutContainer getRootMeasureSpec:self.superview.frame.size.height - self.layoutParams.topMargin - self.layoutParams.bottomMargin rootDimension:WRAP_CONTENT];
            }
            else {
                heightMeasureSpec = [LayoutContainer getRootMeasureSpec:self.superview.frame.size.height - self.layoutParams.topMargin - self.layoutParams.bottomMargin rootDimension:MATCH_PARENT];
            }
            
            [self measure:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
            [self layout:self.layoutParams.leftMargin top:self.layoutParams.topMargin right:[self.layoutParams getMeasuredWidth] + self.layoutParams.leftMargin bottom:[self.layoutParams getMeasuredHeight] + self.layoutParams.topMargin];
        }
        else {
            CGRect frame = self.frame;
            MeasureSpec widthMeasureSpec;
            widthMeasureSpec.size = frame.size.width;
            widthMeasureSpec.mode = EXACTLY;
            
            MeasureSpec heightMeasureSpec;
            heightMeasureSpec.size = frame.size.height;
            heightMeasureSpec.mode = EXACTLY;
            
            [self measure:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
            [self layout:frame.origin.x top:frame.origin.y right:frame.size.width + frame.origin.x bottom:frame.size.height + frame.origin.y];
        }
    }
}

- (void) measure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    if (self.layoutContainer) {
        [self.layoutContainer onMeasure:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
    else {
        [self onMeasure:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
}

- (void) layout:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
    [self onLayout:left top:top right:right bottom:bottom];
    if (self.layoutContainer) {
        [self.layoutContainer onLayout:left top:top right:right bottom:bottom];
    }
}

- (void) onMeasure:(MeasureSpec)widthMeasureSpec heightMeasureSpec:(MeasureSpec)heightMeasureSpec
{
    if (self.layoutDelegate && [self.layoutDelegate respondsToSelector:@selector(onMeasure:widthMeasureSpec:heightMeasureSpec:)]) {
        [self.layoutDelegate onMeasure:self widthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
    else {
        int widthMode = widthMeasureSpec.mode;
        int heightMode = heightMeasureSpec.mode;
        float widthSize = widthMeasureSpec.size;
        float heightSize = heightMeasureSpec.size;
        
        float width = 0;
        float height = 0;
        
        switch (widthMode) {
                // Parent has imposed an exact size on us
            case EXACTLY: {
                width = widthSize;
            }
                break;
                
                // Parent has imposed a maximum size on us
            case AT_MOST:{
                if (heightMode == EXACTLY) {
                    width = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, heightSize)].width;
                }
                else {
                    width = [self sizeThatFits:CGSizeZero].width;
                }
                
                width = MIN(widthSize, width);
            }
                break;
                
                // Parent asked to see how big we want to be
            case UNSPECIFIED: {
                if (heightMode == EXACTLY) {
                    width = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, heightSize)].width;
                }
                else {
                    width = [self sizeThatFits:CGSizeZero].width;
                }
            }
                break;
        }
        
        switch (heightMode) {
                // Parent has imposed an exact size on us
            case EXACTLY: {
                height = heightSize;
            }
                break;
                
                // Parent has imposed a maximum size on us
            case AT_MOST:{
                if (widthMode == EXACTLY) {
                    height = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
                }
                else {
                    height = [self sizeThatFits:CGSizeZero].height;
                }
                
                height = MIN(heightSize, height);
            }
                break;
                
                // Parent asked to see how big we want to be
            case UNSPECIFIED: {
                if (widthMode == EXACTLY) {
                    height = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
                }
                else {
                    height = [self sizeThatFits:CGSizeZero].height;
                }
            }
                break;
        }
        
        width = MAX(self.layoutParams.minWidth, width);
        height = MAX(self.layoutParams.minHeight, height);
        
        MeasuredDimension widthDimension;
        widthDimension.state = 0;
        widthDimension.size = width;
        
        MeasuredDimension heightDimension;
        heightDimension.state = 0;
        heightDimension.size = height;
        [self.layoutParams setMeasuredDimension:widthDimension height:heightDimension];
    }
}

- (BOOL) onLayout:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
    BOOL changed = NO;
    if (self.layoutDelegate && [self.layoutDelegate respondsToSelector:@selector(onLayout:left:top:right:bottom:)]) {
        changed = [self.layoutDelegate onLayout:self left:left top:top right:right bottom:bottom];
    }
    else if (self.layoutParams) {
        CGRect frame = self.frame;
        if (frame.origin.x != left || frame.origin.x + frame.size.width != right || frame.origin.y != top || frame.origin.y + frame.size.height != bottom) {
            changed = YES;
            
            float newWidth = right - left;
            float newHeight = bottom - top;
            BOOL sizeChanged = (newWidth != frame.size.width) || (newHeight != frame.size.height);
            
            [self setFrame:CGRectMake(left, top, (right - left), (bottom - top))];
            
            if (sizeChanged) {
                [self onSizeChanged:newWidth newHeight:newHeight oldWidth:frame.size.width oldHeight:frame.size.height];
            }
        }
    }
    
    return changed;
}

- (void) onSizeChanged:(float)newWidth newHeight:(float)newHeight oldWidth:(float)oldWidth oldHeight:(float)oldHeight
{
    if (self.layoutDelegate && [self.layoutDelegate respondsToSelector:@selector(onSizeChanged:newWidth:newHeight:oldWidth:oldHeight:)]) {
        [self.layoutDelegate onSizeChanged:self newWidth:newWidth newHeight:newHeight oldWidth:oldWidth oldHeight:oldHeight];
    }
}

- (void)scaleAspectFitHeight:(CGSize)contentSize viewWidth:(CGFloat)width
{
    if (width > 0 && contentSize.width > 0 && contentSize.height > 0) {
        CGFloat height = (contentSize.height / contentSize.width) * width;
        self.layoutParams.width = width;
        self.layoutParams.height = height;
    }
}

@end
