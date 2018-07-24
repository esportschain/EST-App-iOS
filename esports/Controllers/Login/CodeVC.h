//
//  CodeVC.h
//  esports
//
//  Created by 焦龙 on 2018/6/12.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginVC.h"

@interface CodeVC : BaseViewController

@property (nonatomic, strong) LoginVC *loginVC;
@property (nonatomic, strong) NSString *emailStr;

@end
