//
//  VerifyAccountVC.h
//  esports
//
//  Created by 焦龙 on 2018/7/18.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "BaseViewController.h"
#import "WalletVC.h"

@interface VerifyAccountVC : BaseViewController

@property (nonatomic, strong) WalletVC *walletVC;

- (id)initWithBindId:(NSString *)bindId;

@end
