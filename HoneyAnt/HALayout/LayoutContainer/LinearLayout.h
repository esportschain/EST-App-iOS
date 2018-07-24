//
//  LinearLayout.h
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
 * LinearLayout orientation
 */
#define HORIZONTAL  (0)
#define VERTICAL    (1)

/**
 * LinearLayoutParams
 */
@interface LinearLayoutParams : MarginLayoutParams
@property(nonatomic, assign) float weight;
@property(nonatomic, assign) int gravity;

@end

/**
 * LinearLayout
 */
@interface LinearLayout : LayoutContainer
@property(nonatomic, assign) int orientation;
@property(nonatomic, assign) int gravity;
@property(nonatomic, assign) float weightSum;
@property(nonatomic, assign) BOOL useLargestChild;

+(LinearLayout*) layout;

@end
