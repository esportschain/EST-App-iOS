//
//  HAUtil.h
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

#ifndef HoneyAnt_Util_h
#define HoneyAnt_Util_h

#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"DLog --- %s [Line %d] \n\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #define DLog_Condition(condition, xx, ...) {if((condition)) {DLog(xx, ##__VA_ARGS__);}} ((void)0)
    #define BeginTimeClock unsigned long timeClockBegin = clock();
    #define EndTimeClock(name) NSLog(@"%@ --- time: %lu\n", name, (clock() - timeClockBegin) / 1000);
#else
    #define DLog(...)
    #define DLog_Condition(condition, xx, ...) ((void)0)
    #define BeginTimeClock
    #define EndTimeClock(name)
#endif

#define kScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight   [[UIScreen mainScreen] bounds].size.height
#define kSystemVersion  [[UIDevice currentDevice].systemVersion floatValue]

// fix category bug
#define TT_FIX_CATEGORY_BUG(name) @interface TT_FIX_CATEGORY_BUG_##name:NSObject @end \
@implementation TT_FIX_CATEGORY_BUG_##name @end

#endif // HoneyAnt_Util_h
