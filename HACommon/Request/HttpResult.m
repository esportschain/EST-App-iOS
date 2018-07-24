//
//  HttpResult.m
//  aimdev
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

#import "HttpResult.h"
#import "ApiCommonData.h"
#import "HAModel.h"
#import "HADataWrapperParser.h"

@implementation HttpResult


- (id)init
{
    self = [super init];
    if (self) {
        self.code = 1; // default failed
        self.resultCode = 0;
    }
    
    return self;
}

- (void)parseDataWrapper:(HADataWrapper*)dataWrapper
{
    if ([[dataWrapper stringForKey:@"code"] length] <= 0 && [[dataWrapper stringForKey:@"result"] length] <= 0) {
        return;
    }
    
    self.code = [dataWrapper intForKey:@"code"];
    self.resultCode = [dataWrapper intForKey:@"result"];
    self.message = [dataWrapper stringForKey:@"msg"];
    self.data = [dataWrapper dataWrapperForKey:@"data"];
    self.common = [dataWrapper dataWrapperForKey:@"common"];
    self.ret = [dataWrapper stringForKey:@"ret"];
    
    [[ApiCommonData sharedInstance] parseDataWrapper:[dataWrapper dataWrapperForKey:@"common"]];
}

+ (void)parseModelItems:(NSMutableArray<HAModel*> *)modelItems dataWrapper:(HADataWrapper*)dataWrapper modelItemClassName:(NSString*)modelItemClassName
{
    if (modelItems && dataWrapper && modelItemClassName) {
        NSInteger count = [dataWrapper count];
        for (int i = 0; i < count; i ++) {
            HADataWrapper* itemWrapper = [dataWrapper dataWrapperForIndex:i];
            id<HADataWrapperParser> modelItem = [[NSClassFromString(modelItemClassName) alloc] init];
            [modelItem parseDataWrapper:itemWrapper];
            [modelItems addObject:modelItem];
        }
    }
}

@end
