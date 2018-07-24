//
//  RelativeLayout.h
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

/**
 * RelativeLayoutParams
 */
@interface RelativeLayoutParams : MarginLayoutParams
@property(nonatomic, assign) BOOL centerHorizontal;
@property(nonatomic, assign) BOOL centerVertical;

@property(nonatomic, assign) BOOL alignWithParent;

@property(nonatomic, assign) BOOL alignParentLeft;
@property(nonatomic, assign) BOOL alignParentRight;
@property(nonatomic, assign) BOOL alignParentTop;
@property(nonatomic, assign) BOOL alignParentBottom;

@property(nonatomic, weak) UIView* leftOf;
@property(nonatomic, weak) UIView* rightOf;
@property(nonatomic, weak) UIView* aboveOf;
@property(nonatomic, weak) UIView* belowOf;

@property(nonatomic, weak) UIView* alignLeft;
@property(nonatomic, weak) UIView* alignRight;
@property(nonatomic, weak) UIView* alignTop;
@property(nonatomic, weak) UIView* alignBottom;

@end

/**
 * RelativeLayout
 */
@interface RelativeLayout : LayoutContainer

+(RelativeLayout*) layout;

@end

