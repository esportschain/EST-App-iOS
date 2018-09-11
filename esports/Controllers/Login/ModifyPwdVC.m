//
//  ModifyPwdVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/15.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "ModifyPwdVC.h"

@interface ModifyPwdVC ()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UITextField *oldpwdTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UITextField *confirmTF;
@property (nonatomic, strong) UIButton *finishBtn;

@end

@implementation ModifyPwdVC

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
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
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
            
            UIView *topView = [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                if (IS_IPHONE_X) {
                    params.height = 24;
                } else {
                    params.height = 0;
                }
            }];
            
            [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = 68;
                params.height = 44;
                params.topMargin = 20;
                params.belowOf = topView;
                
                [layout setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
                [layout setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
                [layout bk_addEventHandler:^(id sender) {
                    [self.navigationController popViewControllerAnimated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
            }];
            
            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 32;
                params.centerHorizontal = YES;
                params.belowOf = topView;
                
                layout.text = @"Modify Password";
                layout.textColor = kColorBlack;
                layout.font = kNormalFont(16);
            }];
            
            [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 1;
                params.alignParentBottom = YES;
                
                layout.backgroundColor = kColorF0F0F0;
            }];
        }];
        
        UILabel *oldpwdLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.belowOf = navBar;
            params.topMargin = 24;
            params.leftMargin = 14;
            
            layout.text = @"Your old password";
            layout.textColor = kColorBlack;
            layout.font = kNormalFont(16);
        }];
        
        self.oldpwdTF = [UITextField build:layout config:^(RelativeLayoutParams *params, UITextField *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = oldpwdLbl;
            params.topMargin = 12;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 4.0;
            layout.font = kNormalFont(16);
            layout.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
            layout.leftViewMode = UITextFieldViewModeAlways;
            layout.secureTextEntry = YES;
            [layout addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        UILabel *passwordLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.belowOf = self.oldpwdTF;
            params.topMargin = 24;
            params.leftMargin = 14;
            
            layout.text = @"Set a different password";
            layout.textColor = kColorBlack;
            layout.font = kNormalFont(16);
        }];
        
        self.passwordTF = [UITextField build:layout config:^(RelativeLayoutParams *params, UITextField *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = passwordLbl;
            params.topMargin = 12;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 4.0;
            layout.font = kNormalFont(16);
            layout.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
            layout.leftViewMode = UITextFieldViewModeAlways;
            layout.secureTextEntry = YES;
            NSMutableDictionary *attris = [NSMutableDictionary dictionary];
            attris[NSForegroundColorAttributeName] = kColorGray;
            layout.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"include numbers, letters, special characters" attributes:attris];
            [layout addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        UILabel *confirmLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.belowOf = self.passwordTF;
            params.topMargin = 24;
            params.leftMargin = 14;
            
            layout.text = @"Enter your password again";
            layout.textColor = kColorBlack;
            layout.font = kNormalFont(16);
        }];
        
        self.confirmTF = [UITextField build:layout config:^(RelativeLayoutParams *params, UITextField *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = confirmLbl;
            params.topMargin = 12;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 4.0;
            layout.font = kNormalFont(16);
            layout.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
            layout.leftViewMode = UITextFieldViewModeAlways;
            layout.secureTextEntry = YES;
            [layout addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        self.finishBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = self.confirmTF;
            params.topMargin = 26;
            
            [layout setTitle:@"Finish" forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
            layout.backgroundColor = kColorC3CBCF;
            layout.enabled = NO;
            [layout.titleLabel setFont:kNormalFont(16)];
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                if (![self.passwordTF.text isEqualToString:self.confirmTF.text]) {
                    [MBProgressHUDHelper showError:@"Different passwords." complete:nil];
                } else if ([self.passwordTF.text length] < 6 || [self.passwordTF.text length] > 16) {
                    [MBProgressHUDHelper showError:@"The password must be between 6-16 digits, Alphanumeric combination" complete:nil];
                } else if ([self.confirmTF.text length] < 6 || [self.confirmTF.text length] > 16) {
                    [MBProgressHUDHelper showError:@"The password must be between 6-16 digits, Alphanumeric combination" complete:nil];
                } else if (![self isValidPasswordString]) {
                    [MBProgressHUDHelper showError:@"Your password must contain a mix of numbers, letters and special characters." complete:nil];
                } else {
                    [self goCommit];
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
    
    [self.rootLayout requestLayout];
}

- (void)goCommit {
    MBProgressHUD *hud = [MBProgressHUDHelper showLoading:@""];
    
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"modifyPwd" forKey:@"m"];
    
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
    NSString *old_pwdMD5 = [HAStringUtil md5:self.oldpwdTF.text];
    [paramDic setObject:old_pwdMD5 forKey:@"old_pwd"];
    NSString *new_pwdMD5 = [HAStringUtil md5:self.passwordTF.text];
    [paramDic setObject:new_pwdMD5 forKey:@"new_pwd"];
    NSString *rnew_pwdMD5 = [HAStringUtil md5:self.confirmTF.text];
    [paramDic setObject:rnew_pwdMD5 forKey:@"rnew_pwd"];
    
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
    [task.request.params setValue:old_pwdMD5 forKey:@"old_pwd"];
    [task.request.params setValue:new_pwdMD5 forKey:@"new_pwd"];
    [task.request.params setValue:rnew_pwdMD5 forKey:@"rnew_pwd"];
    task.request.method = HttpMethodPost;
    
    [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
        [hud hideAnimated:YES];
        
        if (task.status == HttpTaskStatusSucceeded) {
            HttpResult* result = (HttpResult*)task.result;
            if (result.code == HTTP_RESULT_SUCCESS) {
                [MBProgressHUDHelper showSuccess:@"Modify successfully. Please re-login." complete:^(void) {
                    [AccountManager sharedInstance].account.userId = @"";
                    [AccountManager sharedInstance].account.token = @"";
                    [AccountManager sharedInstance].account.authKey = @"-1";
                    [AccountManager sharedInstance].account.nickname = @"";
                    [AccountManager sharedInstance].account.avatar = @"";
                    [AccountManager sharedInstance].account.isEmailLogin = NO;
                    [[AccountManager sharedInstance] saveAccountInfoToDisk];
                    
                    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
                    [[SDImageCache sharedImageCache] clearMemory];
                    
                    [theAppDelegate startOver];
                }];
                
//                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [MBProgressHUDHelper showError:result.message complete:nil];
            }
        }
        else {
            [MBProgressHUDHelper showError:@"Connection Failed" complete:nil];
        }
    }];
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGr {
    [self.oldpwdTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.confirmTF resignFirstResponder];
}

- (void)textFieldDidChangeValue:(id)sender {
    if (![self.oldpwdTF.text isEqualToString:@""] && ![self.passwordTF.text isEqualToString:@""] && ![self.confirmTF.text isEqualToString:@""]) {
        self.finishBtn.backgroundColor = kColor31B4FF;
        self.finishBtn.enabled = YES;
    } else {
        self.finishBtn.backgroundColor = kColorC3CBCF;
        self.finishBtn.enabled = NO;
    }
}

-(BOOL)isValidPasswordString {
    BOOL result = NO;
    
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:self.passwordTF.text options:NSMatchingReportProgress range:NSMakeRange(0, [self.passwordTF.text length])];
    
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合英文字条件的有几个
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:self.passwordTF.text options:NSMatchingReportProgress range:NSMakeRange(0, [self.passwordTF.text length])];
    
    //特殊字符条件
    NSRegularExpression *tSpecialRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[~!@#$%^&*?_-]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合特殊字符条件的有几个
    NSUInteger tSpecialMatchCount = [tSpecialRegularExpression numberOfMatchesInString:self.passwordTF.text options:NSMatchingReportProgress range:NSMakeRange(0, [self.passwordTF.text length])];
    
    if(tNumMatchCount >= 1 && tLetterMatchCount >= 1 && tSpecialMatchCount >= 1){
        result = YES;
    }
    
    return result;
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
