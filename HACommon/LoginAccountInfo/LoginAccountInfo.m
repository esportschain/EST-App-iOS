//
//  LoginAccountInfo.m
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "LoginAccountInfo.h"
//#import "BPush.h"

@implementation LoginAccountInfo
SYNTHESIZE_SINGLETON_FOR_CLASS(LoginAccountInfo)
- (id)init
{
    self = [super init];
    if(self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.accessToken = [userDefaults objectForKey:@"LoginAccountInfo_accessToken"];
        self.tokenSecret = [userDefaults objectForKey:@"LoginAccountInfo_tokenSecret"];
        self.uid = [userDefaults objectForKey:@"LoginAccountInfo_uid"];
        self.uname = [userDefaults objectForKey:@"LoginAccountInfo_uname"];
        self.avatar = [userDefaults objectForKey:@"LoginAccountInfo_avatar"];
        self.signature = [userDefaults objectForKey:@"LoginAccountInfo_signature"];
        self.gender = [[userDefaults objectForKey:@"LoginAccountInfo_gender"] integerValue];
    }
    
    return self;
}

- (void)login:(id)canceler uname:(NSString*)uname password:(NSString*)password complete:(HAHttpTaskCompletedBlock)completeBlock
{
    HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:canceler path:nil];
    [task.request.params setValue:@"login" forKey:@"module"];
    [task.request.params setValue:uname forKey:@"x_auth_username"];
    [task.request.params setValue:password forKey:@"x_auth_password"];
    [task.request.params setValue:@"client_auth" forKey:@"x_auth_mode"];
    [task addFilter:self];
    [[HttpRequest sharedInstance] execute:task complete:completeBlock];
}

- (void)register:(id)canceler uname:(NSString*)uname password:(NSString*)password email:(NSString*)email complete:(HAHttpTaskCompletedBlock)completeBlock
{
    HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:canceler path:nil];
    [task.request.params setValue:@"register" forKey:@"module"];
    [task.request.params setValue:uname forKey:@"username"];
    [task.request.params setValue:password forKey:@"password"];
    [task.request.params setValue:email forKey:@"email"];
    [task addFilter:self];
    [[HttpRequest sharedInstance] execute:task complete:completeBlock];
}

- (void)logout
{
    self.accessToken = nil;
    self.tokenSecret = nil;
    self.uid = nil;
    self.uname = nil;
    self.avatar = nil;
    self.signature = nil;
    self.gender = 0;
    
    [self save];
}

- (void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.accessToken forKey:@"LoginAccountInfo_accessToken"];
    [userDefaults setValue:self.tokenSecret forKey:@"LoginAccountInfo_tokenSecret"];
    [userDefaults setValue:self.uid forKey:@"LoginAccountInfo_uid"];
    [userDefaults setValue:self.uname forKey:@"LoginAccountInfo_uname"];
    [userDefaults setValue:self.avatar forKey:@"LoginAccountInfo_avatar"];
    [userDefaults setValue:self.signature forKey:@"LoginAccountInfo_signature"];
    [userDefaults setValue:[NSNumber numberWithInt:self.gender] forKey:@"LoginAccountInfo_gender"];
    [userDefaults synchronize];
}

- (BOOL) isLogin
{
    return self.accessToken && [self.accessToken length] > 0;
}

#pragma mark - private
- (void)uploadPushInfo
{
    HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:self path:nil];
    [task.request.params setValue:@"updatepushinfo" forKey:@"module"];
    [task.request.params setValue:@"4" forKey:@"device_type"];
    [task.request.params setValue:self.pushToken forKey:@"device_token"];
    [task.request.params setValue:@"aimdeveloper" forKey:@"tag"];
//    [task.request.params setValue:[BPush getUserId] forKey:@"user_id"];
//    [task.request.params setValue:[BPush getChannelId] forKey:@"channel_id"];
    [[HttpRequest sharedInstance] execute:task complete:nil];

}

#pragma mark - HAHttpTaskSucceededFilter
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    HttpResult* result = (HttpResult*)task.result;
    if (result.code == HTTP_RESULT_SUCCESS) {
        [self parseDataWrapper:result.data];
        [self uploadPushInfo];
    }
}

#pragma mark - HADataWrapperParser
-(void) parseDataWrapper:(HADataWrapper*)dataWrapper
{
    self.accessToken = [dataWrapper stringForKey:@"oauth_token"];
    self.tokenSecret = [dataWrapper stringForKey:@"oauth_token_secret"];
    self.uid = [dataWrapper stringForKey:@"uid"];
    self.uname = [dataWrapper stringForKey:@"username"];
    self.avatar = [dataWrapper stringForKey:@"avatar"];
    self.signature = [dataWrapper stringForKey:@"signature"];
    self.gender = [dataWrapper intForKey:@"gender"];
    
    [self save];
}

@end
