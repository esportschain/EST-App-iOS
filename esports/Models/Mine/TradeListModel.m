//
//  TradeListModel.m
//  esports
//
//  Created by 焦龙 on 2018/6/21.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "TradeListModel.h"

@implementation TradeListItemModel
@synthesize cellHeight;
- (void) parseDataWrapper:(HADataWrapper *)dataWrapper
{
    self.tradeName = [dataWrapper stringForKey:@"name"];
    self.timeStr = [dataWrapper stringForKey:@"creation"];
    self.type = [dataWrapper intForKey:@"type"];
    self.amount = [dataWrapper stringForKey:@"money"];
}

@end

@implementation TradeListModel

#pragma mark - HAHttpTaskBuildParamsFilter
- (void)onHAHttpTaskBuildParamsFilterExecute:(HAHttpTask*)task
{
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"wallet" forKey:@"m"];
    
    //拼好get参数
    NSArray *keys = [paramDic allKeys];
    NSString *getStr = @"";
    for (NSString *key in keys) {
        getStr = [getStr stringByAppendingString:[NSString stringWithFormat:@"%@=", key]];
        NSString *encodeStr = [HAURLUtil urlEncode:[paramDic objectForKey:key]];
        getStr = [getStr stringByAppendingString:[NSString stringWithFormat:@"%@&", encodeStr]];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *tsStr = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    NSString *paramStr = [NSString stringWithFormat:@"%@|ios|%@|%@|1|%@|%@|%@", [AccountManager sharedInstance].account.idfv, build, version, tsStr, [AccountManager sharedInstance].account.userId, [AccountManager sharedInstance].account.token];
    
    //加入公共参数
    [paramDic setObject:paramStr forKey:@"_param"];
    //加入post参数
    if (![self.page isEqualToString:@"1"]) {
        [paramDic setObject:self.page forKey:@"page"];
    }
    
    NSArray *newKeys = [paramDic allKeys];
    NSArray *sortKeys = [newKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSString *sigStr = @"";
    for (NSString *key in sortKeys) {
        sigStr = [sigStr stringByAppendingString:[NSString stringWithFormat:@"%@", [paramDic objectForKey:key]]];
    }
    
    NSString *sigStr1 = [NSString stringWithFormat:@"%@%@%@", sigStr, PUBLIC_KEY, [AccountManager sharedInstance].account.authKey];
    NSString *sigMD5_1 = [HAStringUtil md5:sigStr1];
    NSString *sigMD5_2 = [HAStringUtil md5:sigMD5_1];
    
    NSString *pathStr = [NSString stringWithFormat:@"%@_param=%@&sig=%@", getStr, [HAURLUtil urlEncode:paramStr], sigMD5_2];
    
    task.request.url = MAIN_API_URL(pathStr);
}

#pragma mark - HAHttpTaskSucceededFilter
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    HttpResult* result = (HttpResult*)task.result;
    if (result.code == HTTP_RESULT_SUCCESS) {
        HADataWrapper* listWrapper = [result.data dataWrapperForKey:@"list"];
        [HttpResult parseModelItems:self.modelItems dataWrapper:listWrapper modelItemClassName:NSStringFromClass([TradeListItemModel class])];
    }
}

@end
