//
//  PasswordVC.h
//  esports
//
//  Created by 焦龙 on 2018/6/14.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginVC.h"

@interface PasswordVC : BaseViewController

@property (nonatomic, strong) LoginVC *loginVC;
@property (nonatomic, strong) NSString *emailStr;
@property (nonatomic, strong) NSString *registerKey;

@end
