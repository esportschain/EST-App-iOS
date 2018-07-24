//
//  LoginAccountInfo.h
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAObject.h"

@interface LoginAccountInfo : HAObject<HADataWrapperParser, HAHttpTaskSucceededFilter>

@property(nonatomic, strong) NSString* accessToken;
@property(nonatomic, strong) NSString* tokenSecret;
@property(nonatomic, strong) NSString* uid;
@property(nonatomic, strong) NSString* uname;
@property(nonatomic, strong) NSString* avatar;
@property(nonatomic, strong) NSString* signature;
@property(nonatomic, assign) NSInteger gender; // 0-未知，1-男，2-女

@property(nonatomic, strong) NSString* pushToken;

- (void)login:(id)canceler uname:(NSString*)uname password:(NSString*)password complete:(HAHttpTaskCompletedBlock)completeBlock;
- (void)register:(id)canceler uname:(NSString*)uname password:(NSString*)password email:(NSString*)email complete:(HAHttpTaskCompletedBlock)completeBlock;
- (void)logout;
- (void)save;
- (BOOL)isLogin;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(LoginAccountInfo)
@end
