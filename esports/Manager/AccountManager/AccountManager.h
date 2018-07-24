//
//  AccountManager.h
//  Dishes
//
//  Created by 焦龙 on 2016/10/13.
//  Copyright © 2016年 caijieit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountModel.h"

@interface AccountManager : NSObject

@property (nonatomic, strong) AccountModel *account;

+ (AccountManager *)sharedInstance;

- (void)saveAccountInfoToDisk;
- (void)loadAccountInfoFromDisk;

@end
