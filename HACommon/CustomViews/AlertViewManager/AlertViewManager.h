//
//  AlertViewManager.h
//  yilingdoctorCRM
//
//  Created by zhangxi on 14/10/28.
//  Copyright (c) 2014年 yuntai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertViewManager : NSObject

+ (void)showAlertViewWithMessage:(NSString *)message;

+ (void)showAlertViewSuccessedMessage:(NSString *)message handlerBlock:(void(^)())handlerBlock;

+ (void)showAlertViewLogOutHandlerBlock:(void(^)())handlerBlock;

+ (void)showAlertViewWithMessage:(NSString *)message handlerBlock:(void(^)())handlerBlock;

+ (void)showAlertViewWithMessage:(NSString *)message handlerBlock:(void(^)())handlerBlock  cancelBlock:(void(^)())cancelBlock;


+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle confirmButtonTitle:(NSString *)confirmTitle handlerBlock:(void(^)())handlerBlock cancelBlock:(void(^)())cancelBlock;

@end
