//
//  LoginVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/11.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "LoginVC.h"
#import "EmailVC.h"
#import "ThirdLoginVC.h"
#import "EmailLoginVC.h"

@interface LoginVC ()

@property (nonatomic, strong) UIView *rootLayout;

@end

@implementation LoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hideNavigationBar = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [[HttpRequest sharedInstance] cancelTaskByCanceler:self];
    
    [[HANotificationCenter sharedInstance] removeNotificationObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rootLayout = [UIView build:self.view container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
        
        params.width = MATCH_PARENT;
        params.height = MATCH_PARENT;
        params.topMargin = IS_IOS_7? 0:64;
        
        layout.backgroundColor = kColorWhite;
        
        UIView *navBar = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            if (IS_IPHONE_X) {
                params.height = 88;
            } else {
                params.height = 64;
            }
        }];
        
        UIImageView *logoIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
            params.belowOf = navBar;
            params.topMargin = 40;
            
            layout.image = Image(@"logo_logo");
        }];
        
        UILabel *titleLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
            params.belowOf = logoIV;
            params.topMargin = 12;
            
            layout.text = @"ESports Chain";
            layout.textColor = kColorBlack;
            layout.font = kBoldFont(18);
        }];
        
        UILabel *contentLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = 214;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
            params.belowOf = titleLbl;
            params.topMargin = 20;
            
            layout.text = @"exchange your game stats for ESports Token, and minie EST by playing your favourite computer game.";
            layout.textColor = kColorGray;
            layout.font = kNormalFont(14);
            layout.numberOfLines = 0;
            layout.textAlignment = NSTextAlignmentCenter;
        }];
        
        UIButton *steamBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = (kDeviceWidth - 38) / 2;
            params.height = 48;
            params.leftMargin = 14;
            params.belowOf = contentLbl;
            params.topMargin = 90;
            
            [layout setImage:Image(@"btn_steam") forState:UIControlStateNormal];
            [layout setImage:Image(@"btn_steam") forState:UIControlStateHighlighted];
            [layout setTitle:@"Steam" forState:UIControlStateNormal];
            [layout setTitle:@"Steam" forState:UIControlStateHighlighted];
            [layout setTitleColor:kColorBlack forState:UIControlStateNormal];
            [layout setTitleColor:kColorBlack forState:UIControlStateHighlighted];
            [layout setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [layout.titleLabel setFont:kNormalFont(14)];
            layout.layer.borderWidth = 1.0;
            layout.layer.borderColor = kColorF0F0F0.CGColor;
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                [self loginWithType:1];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
        
        [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = (kDeviceWidth - 38) / 2;
            params.height = 48;
            params.rightOf = steamBtn;
            params.leftMargin = 10;
            params.belowOf = contentLbl;
            params.topMargin = 90;
            
            [layout setImage:Image(@"btn_facebook") forState:UIControlStateNormal];
            [layout setImage:Image(@"btn_facebook") forState:UIControlStateHighlighted];
            [layout setTitle:@"Facebook" forState:UIControlStateNormal];
            [layout setTitle:@"Facebook" forState:UIControlStateHighlighted];
            [layout setTitleColor:kColorBlack forState:UIControlStateNormal];
            [layout setTitleColor:kColorBlack forState:UIControlStateHighlighted];
            [layout setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [layout.titleLabel setFont:kNormalFont(14)];
            layout.layer.borderWidth = 1.0;
            layout.layer.borderColor = kColorF0F0F0.CGColor;
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                [self loginWithType:2];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
        
        UIButton *emailBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = steamBtn;
            params.topMargin = 12;
            
            [layout setTitle:@"Login with Email" forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
            layout.backgroundColor = kColor31B4FF;
            [layout.titleLabel setFont:kNormalFont(14)];
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                EmailLoginVC *emailLoginVC = [[EmailLoginVC alloc] init];
                [self.navigationController pushViewController:emailLoginVC animated:YES];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
        
        [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
            
            params.width = kDeviceWidth - 80;
            params.height = 0.5;
            params.centerHorizontal = YES;
            params.belowOf = emailBtn;
            params.topMargin = 35;
            
            layout.backgroundColor = kColorF0F0F0;
        }];
        
        UILabel *orLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = 30;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
            params.belowOf = emailBtn;
            params.topMargin = 26;
            
            layout.text = @"or";
            layout.textColor = kColorLightGray;
            layout.font = kNormalFont(14);
            layout.backgroundColor = kColorWhite;
            layout.textAlignment = NSTextAlignmentCenter;
        }];
        
        [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = orLbl;
            params.topMargin = 10;
            
            NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:@"Sign up with email"];
            [tncString addAttribute:NSUnderlineStyleAttributeName
                              value:@(NSUnderlineStyleSingle)
                              range:(NSRange){0,[tncString length]}];
            //此时如果设置字体颜色要这样
            [tncString addAttribute:NSForegroundColorAttributeName value:kColor31B4FF range:NSMakeRange(0,[tncString length])];
            //设置下划线颜色
            [tncString addAttribute:NSUnderlineColorAttributeName value:kColor31B4FF range:(NSRange){0,[tncString length]}];
            [layout setAttributedTitle:tncString forState:UIControlStateNormal];
            [layout.titleLabel setFont:kNormalFont(14)];
            [layout bk_addEventHandler:^(id sender) {
                EmailVC *emailVC = [[EmailVC alloc] init];
                emailVC.loginVC = self;
                [self.navigationController pushViewController:emailVC animated:YES];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
    
    [self.rootLayout requestLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"NOTI_LOGIN_SUCCESS" object:nil];
}

- (void)loginSuccess {
    [self.navigationController popViewControllerAnimated:NO];
    [theAppDelegate loadMain];
    [self updateInfo];
}

- (void)updateInfo {
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"updated" forKey:@"m"];
    
    //拼好get参数
    NSArray *keys = [paramDic allKeys];
    NSString *getStr = @"";
    for (NSString *key in keys) {
        getStr = [getStr stringByAppendingString:[NSString stringWithFormat:@"%@=", key]];
        NSString *encodeStr = [HAURLUtil urlEncode:[paramDic objectForKey:key]];
        getStr = [getStr stringByAppendingString:[NSString stringWithFormat:@"%@&", encodeStr]];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *tsStr = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    NSString *paramStr = [NSString stringWithFormat:@"%@|ios|%@|%@|1|%@|%@|%@", [AccountManager sharedInstance].account.idfv, build, version, tsStr, [AccountManager sharedInstance].account.userId, [AccountManager sharedInstance].account.token];
    
    //加入公共参数
    [paramDic setObject:paramStr forKey:@"_param"];
    //加入post参数
    [paramDic setObject:[AccountManager sharedInstance].account.deviceToken forKey:@"device_token"];
    
    NSArray *newKeys = [paramDic allKeys];
    NSArray *sortKeys = [newKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSString *sigStr = @"";
    for (NSString *key in sortKeys) {
        sigStr = [sigStr stringByAppendingString:[NSString stringWithFormat:@"%@", [paramDic objectForKey:key]]];
    }
    
    NSString *sigStr1 = [NSString stringWithFormat:@"%@%@%@", sigStr, PUBLIC_KEY, [AccountManager sharedInstance].account.authKey];
    NSString *sigMD5_1 = [HAStringUtil md5:sigStr1];
    NSString *sigMD5_2 = [HAStringUtil md5:sigMD5_1];
    
    HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:self path:[NSString stringWithFormat:@"%@_param=%@&sig=%@", getStr, [HAURLUtil urlEncode:paramStr], sigMD5_2]];
    [task.request.params setValue:[AccountManager sharedInstance].account.deviceToken forKey:@"device_token"];
    task.request.method = HttpMethodPost;
    
    [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
        if (task.status == HttpTaskStatusSucceeded) {
            HttpResult* result = (HttpResult*)task.result;
            if (result.code == HTTP_RESULT_SUCCESS) {
                
            }
            else {
                [MBProgressHUDHelper showError:result.message complete:nil];
            }
        }
        else {
            [MBProgressHUDHelper showError:@"网络请求失败" complete:nil];
        }
    }];
}

- (void)loginWithType:(NSInteger)type {
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"thirdLogin" forKey:@"m"];
    [paramDic setObject:[NSString stringWithFormat:@"%ld", type] forKey:@"thirdtype"];
    
    //拼好get参数
    NSArray *keys = [paramDic allKeys];
    NSString *getStr = @"";
    for (NSString *key in keys) {
        getStr = [getStr stringByAppendingString:[NSString stringWithFormat:@"%@=", key]];
        NSString *encodeStr = [HAURLUtil urlEncode:[paramDic objectForKey:key]];
        getStr = [getStr stringByAppendingString:[NSString stringWithFormat:@"%@&", encodeStr]];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *tsStr = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    NSString *paramStr = [NSString stringWithFormat:@"%@|ios|%@|%@|1|%@|%@|%@", [AccountManager sharedInstance].account.idfv, build, version, tsStr, [AccountManager sharedInstance].account.userId, [AccountManager sharedInstance].account.token];
    
    //加入公共参数
    [paramDic setObject:paramStr forKey:@"_param"];
    
    NSArray *newKeys = [paramDic allKeys];
    NSArray *sortKeys = [newKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSString *sigStr = @"";
    for (NSString *key in sortKeys) {
        sigStr = [sigStr stringByAppendingString:[NSString stringWithFormat:@"%@", [paramDic objectForKey:key]]];
    }
    
    NSString *sigStr1 = [NSString stringWithFormat:@"%@%@%@", sigStr, PUBLIC_KEY, [AccountManager sharedInstance].account.authKey];
    NSString *sigMD5_1 = [HAStringUtil md5:sigStr1];
    NSString *sigMD5_2 = [HAStringUtil md5:sigMD5_1];
    
    NSString *pathStr = [NSString stringWithFormat:@"%@_param=%@&sig=%@", getStr, [HAURLUtil urlEncode:paramStr], sigMD5_2];
    
    ThirdLoginVC *thirdLoginVC = [[ThirdLoginVC alloc] initWithURL:MAIN_API_URL(pathStr)];
    [self.navigationController pushViewController:thirdLoginVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
