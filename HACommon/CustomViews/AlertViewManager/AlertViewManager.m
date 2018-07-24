//
//  AlertViewManager.m
//  yilingdoctorCRM
//
//  Created by zhangxi on 14/10/28.
//  Copyright (c) 2014年 yuntai. All rights reserved.
//

#import "AlertViewManager.h"

@implementation AlertViewManager

+ (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

+ (void)showAlertViewSuccessedMessage:(NSString *)message handlerBlock:(void(^)())handlerBlock {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert bk_setHandler:^{
        handlerBlock();
    } forButtonAtIndex:0];
    [alert show];
}

+ (void)showAlertViewLogOutHandlerBlock:(void(^)())handlerBlock {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"退出登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert bk_setHandler:^{
        handlerBlock();
    } forButtonAtIndex:1];
    [alert show];
}

+ (void)showAlertViewWithMessage:(NSString *)message handlerBlock:(void(^)())handlerBlock {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert bk_setHandler:^{
        handlerBlock();
    } forButtonAtIndex:1];
    [alert show];
}

+ (void)showAlertViewWithMessage:(NSString *)message handlerBlock:(void(^)())handlerBlock  cancelBlock:(void(^)())cancelBlock{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert bk_setHandler:^{
        handlerBlock();
    } forButtonAtIndex:1];
    [alert bk_setHandler:^{
        cancelBlock();
    } forButtonAtIndex:0];
    
    [alert show];
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle confirmButtonTitle:(NSString *)confirmTitle handlerBlock:(void(^)())handlerBlock cancelBlock:(void(^)())cancelBlock{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:confirmTitle, nil];
    [alert bk_setHandler:^{
        handlerBlock();
    } forButtonAtIndex:1];
    [alert bk_setHandler:^{
        cancelBlock();
    } forButtonAtIndex:0];
    
    [alert show];
}

@end
