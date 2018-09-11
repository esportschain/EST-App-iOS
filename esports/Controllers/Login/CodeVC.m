//
//  CodeVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/12.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#define COUNT_SEC_NUM     60

#import "CodeVC.h"
#import "PasswordVC.h"

@interface CodeVC ()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UITextField *codeTF;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UILabel *countLbl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int countDown;

@end

@implementation CodeVC

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
                
                layout.text = @"Verification code";
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
        
        UILabel *codeLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.belowOf = navBar;
            params.topMargin = 24;
            params.leftMargin = 14;
            
            layout.text = @"Check inbox and enter verification code";
            layout.textColor = kColorBlack;
            layout.font = kNormalFont(16);
        }];
        
        self.codeTF = [UITextField build:layout config:^(RelativeLayoutParams *params, UITextField *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = codeLbl;
            params.topMargin = 12;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 4.0;
            layout.font = kNormalFont(16);
            layout.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
            layout.leftViewMode = UITextFieldViewModeAlways;
            [layout addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        UILabel *recendLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.centerHorizontal = YES;
            params.belowOf = self.codeTF;
            params.topMargin = 15;
            
            layout.text = @"Resend (         )";
            layout.textColor = kColorGray;
            layout.font = kNormalFont(14);
        }];
        
        self.countLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = 40;
            params.height = WRAP_CONTENT;
            params.rightOf = recendLbl;
            params.leftMargin = -42;
            params.belowOf = self.codeTF;
            params.topMargin = 15;
            
            layout.text = [NSString stringWithFormat:@"%ds", COUNT_SEC_NUM];
            layout.textColor = kColor31B4FF;
            layout.font = kNormalFont(14);
            layout.textAlignment = NSTextAlignmentCenter;
        }];
        
        self.nextBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = recendLbl;
            params.topMargin = 15;
            
            [layout setTitle:@"NEXT" forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
            layout.backgroundColor = kColorC3CBCF;
            layout.enabled = NO;
            [layout.titleLabel setFont:kNormalFont(16)];
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                [self checkVCode];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
    
    [self.rootLayout requestLayout];
    
    self.countDown = COUNT_SEC_NUM;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.timer) {
        self.countLbl.text = @"0s";
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)onTimer {
    self.countDown--;
    self.countLbl.text = [NSString stringWithFormat:@"%ds", self.countDown];
    if (self.countDown == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)checkVCode {
    MBProgressHUD *hud = [MBProgressHUDHelper showLoading:@""];
    
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"checkVcode" forKey:@"m"];
    
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
    [paramDic setObject:self.emailStr forKey:@"email"];
    [paramDic setObject:self.codeTF.text forKey:@"vcode"];
    
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
    [task.request.params setValue:self.emailStr forKey:@"email"];
    [task.request.params setValue:self.codeTF.text forKey:@"vcode"];
    task.request.method = HttpMethodPost;
    
    [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
        [hud hideAnimated:YES];
        
        if (task.status == HttpTaskStatusSucceeded) {
            HttpResult* result = (HttpResult*)task.result;
            if (result.code == HTTP_RESULT_SUCCESS) {
                PasswordVC *passwordVC = [[PasswordVC alloc] init];
                passwordVC.loginVC = self.loginVC;
                passwordVC.emailStr = self.emailStr;
                passwordVC.registerKey = [result.data stringForKey:@"key"];
                [self.navigationController pushViewController:passwordVC animated:YES];
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
    [self.codeTF resignFirstResponder];
}

- (void)textFieldDidChangeValue:(id)sender {
    if (![((UITextField *)sender).text isEqualToString:@""]) {
        self.nextBtn.backgroundColor = kColor31B4FF;
        self.nextBtn.enabled = YES;
    } else {
        self.nextBtn.backgroundColor = kColorC3CBCF;
        self.nextBtn.enabled = NO;
    }
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
