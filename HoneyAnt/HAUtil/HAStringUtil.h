//
//  HAStringUtil.h
//  HoneyAnt
//
//  Created by dongjianbo on 15-2-12.
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
#import "HAObject.h"

@interface HAStringUtil : HAObject

+ (NSString*)sha1:(NSString*)text;
+ (NSString*)md5:(NSString*)text;

+ (BOOL)isEmptyString:(NSString*)string;

+ (NSMutableString*)replaceMatchesInString:(NSMutableString*)sourceStr pattern:(NSString*)pattern withTemplate:(NSString*)tmeplateStr;
+ (BOOL)RegExpMatch:(NSString*)text withPattern:(NSString*)pattern;
+ (NSInteger)hex2Int:(NSString*)text;
+ (BOOL)isPhoneNumberValidate:(NSString *)phone;
@end

