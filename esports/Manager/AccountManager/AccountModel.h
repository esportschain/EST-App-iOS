//
//  AccountModel.h
//  Dishes
//
//  Created by 焦龙 on 2016/10/13.
//  Copyright © 2016年 caijieit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *authKey;
@property (nonatomic, strong) NSString *idfv;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *deviceToken;

@end
