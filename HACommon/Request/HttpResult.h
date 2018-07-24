//
//  HttpResult.h
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

#import <Foundation/Foundation.h>
#import "HAModel.h"
#import "HADataWrapperParser.h"
#import "HADataWrapper.h"

#define HTTP_RESULT_SUCCESS 0

@interface HttpResult : HAModel<HADataWrapperParser>
@property(nonatomic, assign)NSInteger code; // 状态码，大于0为正常 小于零为异常
@property(nonatomic, assign)NSInteger resultCode; // 论坛请求状态码，大于0为正常 小于零为异常
@property(nonatomic, strong)NSString* message; // 提示信息，由后端返回的统一提示信息
@property(nonatomic, strong)HADataWrapper* data; // 返回数据，json对象，包含详细的后端处理数据
@property(nonatomic, strong)HADataWrapper* common;

@property(nonatomic, strong)NSString *ret;

+ (void)parseModelItems:(NSMutableArray<HAModel*> *)modelItems dataWrapper:(HADataWrapper*)dataWrapper modelItemClassName:(NSString*)modelItemClassName;

@end
