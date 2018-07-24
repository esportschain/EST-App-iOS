//
//  HAObject.m
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

#ifdef DEBUG

#import <objc/runtime.h>
#import "HAObject.h"
#define XCODE_COLORS_ESCAPE @"\033["

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#define LOG_FORMAT_PREFIX @"%s [Line %d] \n"

#define ColoredLog(color, fmt, ...) NSLog((XCODE_COLORS_ESCAPE color LOG_FORMAT_PREFIX fmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define DError(xx, ...)  ColoredLog(@"fg255,0,0; " @"ERROR: ", xx, ##__VA_ARGS__)
#define DWarning(xx, ...)  ColoredLog(@"fg255,172,16; " @"WARNING: ", xx, ##__VA_ARGS__)
#define DTips(xx, ...)  ColoredLog(@"fg0,192,255; " @"TIPS: ", xx, ##__VA_ARGS__)
#define DInfo(xx, ...)  ColoredLog(@"fg16,255,172; " @"INFO: ", xx, ##__VA_ARGS__)
static NSMutableDictionary* s_dictFormtDict = nil;

@implementation HAObject

+ (void)initialize
{
    if (s_dictFormtDict != nil) {
        return;
    }
    
    s_dictFormtDict = [[NSMutableDictionary alloc] init];
    [s_dictFormtDict setObject:@"%@" forKey:[NSString stringWithFormat:@"%c", _C_ID]];
    [s_dictFormtDict setObject:@"%@" forKey:[NSString stringWithFormat:@"%c", _C_CLASS]];
    [s_dictFormtDict setObject:@"%c" forKey:[NSString stringWithFormat:@"%c", _C_CHR]];
    [s_dictFormtDict setObject:@"%c" forKey:[NSString stringWithFormat:@"%c", _C_UCHR]];
    [s_dictFormtDict setObject:@"%i" forKey:[NSString stringWithFormat:@"%c", _C_INT]];
    [s_dictFormtDict setObject:@"%i" forKey:[NSString stringWithFormat:@"%c", _C_LNG]];
    [s_dictFormtDict setObject:@"%i" forKey:[NSString stringWithFormat:@"%c", _C_ULNG]];
    [s_dictFormtDict setObject:@"%i" forKey:[NSString stringWithFormat:@"%c", _C_LNG]];
    [s_dictFormtDict setObject:@"%i" forKey:[NSString stringWithFormat:@"%c", _C_ULNG]];
    [s_dictFormtDict setObject:@"%lli" forKey:[NSString stringWithFormat:@"%c", _C_LNG_LNG]];
    [s_dictFormtDict setObject:@"%lli" forKey:[NSString stringWithFormat:@"%c", _C_ULNG_LNG]];
    [s_dictFormtDict setObject:@"%.6f" forKey:[NSString stringWithFormat:@"%c", _C_FLT]];
    [s_dictFormtDict setObject:@"%lli" forKey:[NSString stringWithFormat:@"%c", _C_ULNG_LNG]];
    [s_dictFormtDict setObject:@"%i" forKey:[NSString stringWithFormat:@"%c", _C_BOOL]];
    [s_dictFormtDict setObject:@"%@" forKey:[NSString stringWithFormat:@"%c", _C_ARY_B]];
    [s_dictFormtDict setObject:@"%@" forKey:[NSString stringWithFormat:@"%c", _C_ARY_E]];
    [s_dictFormtDict setObject:@"%p" forKey:[NSString stringWithFormat:@"%c", _C_PTR]];
}

//- (NSString*)description
//{
//    return [HAObject runtimeDescriptionForObject:self];
//}

- (void)show
{
    NSLog(@"%@", [HAObject runtimeDescriptionForObject:self]);
}

+ (NSString*)runtimeDescriptionForObject:(NSObject *)object
{
    @try {
        unsigned int numberOfIvars = 0;
        Class cls = [object class];
        
        NSString* strDes = @"";
        while (cls != [NSObject class]) {
            Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
            
            for (int i=0; i<numberOfIvars; i++) {
                const char *type    = ivar_getTypeEncoding(*(ivars+i));
                NSString *varName   = [NSString stringWithUTF8String:ivar_getName(*(ivars+i))];
                NSString* varValue  = [object valueForKey:varName];
                strDes = [NSString stringWithFormat:@"%@%@[%s] = %@\n", strDes, varName, type, varValue];
            }
            cls = class_getSuperclass(cls);
            free(ivars);
        }
        if ([strDes length]==0) {
            strDes = @"\n==No vars==\n";
        }
        
        strDes = [NSString stringWithFormat:@"%@\n==readonly property :==\n", strDes];
        
        //print readonly property
        cls = [object class];
        while (cls != [NSObject class]) {
            unsigned int numberOfPropertys = 0;
            objc_property_t * properList = class_copyPropertyList(cls, &numberOfPropertys);
            for (int i=0; i<numberOfPropertys; i++) {
                const char *chAttrName = property_getAttributes(*(properList+i)) ;
                NSArray* arrPropertyAttr = [[NSString stringWithUTF8String:chAttrName] componentsSeparatedByString:@","];
                if (![arrPropertyAttr containsObject:@"R"]) {
                    continue;
                }
                
                const char* propertyName =property_getName(*(properList+i));
                SEL sel = NSSelectorFromString([NSString stringWithUTF8String:propertyName]);
                if (sel == nil) {
                    continue;
                }
                
                Method m=  class_getInstanceMethod(cls, sel);
                if (m == nil) {
                    continue;
                }
                
                char * rType = method_copyReturnType(m);
                NSString* strFormt = [s_dictFormtDict objectForKey:[NSString stringWithFormat:@"%c", rType[0]]];
                if (strFormt == nil) {
                    NSLog(@"UnKown Type = %s", rType);
                    continue;
                }
                IMP imp = method_getImplementation(m);
                if (imp == nil) {
                    NSAssert(0, nil);
                    continue;
                }
                strDes = [NSString stringWithFormat:@"%@%s[%s]\n",
                          strDes, propertyName, rType];
            }
            cls = class_getSuperclass(cls);
        }
        
        return   [NSString stringWithFormat:@"\n=======<%@:%p>=========\n"
                  @"%@"
                  @"=========================\n", NSStringFromClass([object class]), object, strDes];
    }
    @catch (NSException *exception) {
        DWarning(@"%@的PrintableObject异常: %@", [self class], exception);
    }
    @finally {
        
    }
}

@end

#endif
