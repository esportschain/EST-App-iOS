//
//  AccountManager.m
//  Dishes
//
//  Created by 焦龙 on 2016/10/13.
//  Copyright © 2016年 caijieit. All rights reserved.
//

#import "AccountManager.h"

@implementation AccountManager

static AccountManager *sharedInstance;

#pragma mark Singleton Model
+ (AccountManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AccountManager alloc] init];
        sharedInstance.account = [[AccountModel alloc] init];
        [sharedInstance loadAccountInfoFromDisk];
    });
    return sharedInstance;
}

- (void)saveAccountInfoToDisk {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:self.account.userId forKey:@"userId"];
    [ud setValue:self.account.token forKey:@"token"];
    [ud setValue:self.account.authKey forKey:@"authKey"];
    [ud setValue:self.account.idfv forKey:@"idfv"];
    [ud setValue:self.account.nickname forKey:@"nickname"];
    [ud setValue:self.account.avatar forKey:@"avatar"];
    [ud setValue:self.account.deviceToken forKey:@"deviceToken"];
    
    [ud synchronize];
    
    [self loadAccountInfoFromDisk];
}

- (void)loadAccountInfoFromDisk {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.account.userId = [ud objectForKey:@"userId"];
    self.account.token = [ud objectForKey:@"token"];
    self.account.authKey = [ud objectForKey:@"authKey"];
    self.account.idfv = [ud objectForKey:@"idfv"];
    self.account.nickname = [ud objectForKey:@"nickname"];
    self.account.avatar = [ud objectForKey:@"avatar"];
    self.account.deviceToken = [ud objectForKey:@"deviceToken"];
}

@end
