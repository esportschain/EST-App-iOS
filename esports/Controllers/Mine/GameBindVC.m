//
//  GameBindVC.m
//  esports
//
//  Created by 焦龙 on 2018/7/18.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "GameBindVC.h"

@interface GameBindVC ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation GameBindVC

- (id)initWithURL:(NSString *)urlStr {
    
    self.urlStr = urlStr;
    
    self = [super initWithNibName:nil bundle:nil];
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
        
        [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
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
                
                layout.text = @"Bind PUBG Account";
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
    }];
    
    [self.rootLayout requestLayout];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, theAppDelegate.tableViewOffset, kDeviceWidth, kDeviceHeight - theAppDelegate.tableViewOffset - theAppDelegate.bottomOffset) configuration:configuration];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"Utils"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"Utils"];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:message.body];
    NSString *method = [dic objectForKey:@"method"];
    
    if ([method isEqualToString:@"callSubmitAccountBind"]) {
        NSString *gameType = [dic objectForKey:@"gametype"];
        NSString *data = [dic objectForKey:@"data"];
        
        MBProgressHUD *hud = [MBProgressHUDHelper showLoading:@""];
        
        //非公共参数字典
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
        [paramDic setObject:@"App" forKey:@"d"];
        [paramDic setObject:@"Member" forKey:@"c"];
        [paramDic setObject:@"bindAccount" forKey:@"m"];
        
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
        [paramDic setObject:gameType forKey:@"gametype"];
        [paramDic setObject:data forKey:@"data"];
        
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
        [task.request.params setValue:gameType forKey:@"gametype"];
        [task.request.params setValue:data forKey:@"data"];
        task.request.method = HttpMethodPost;
        
        [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
            [hud hideAnimated:YES];
            
            if (task.status == HttpTaskStatusSucceeded) {
                HttpResult* result = (HttpResult*)task.result;
                if (result.code == HTTP_RESULT_SUCCESS) {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_BINDGAME_SUCCESS" object:nil];
                }
                else {
                    NSString *javascript = [NSString stringWithFormat:@"callBindFieldAfterAction('%@');", result.ret];
                    
                    [self.webView evaluateJavaScript:javascript completionHandler:^(id _Nullable aaa, NSError * _Nullable error) {
                        DLog(@"%@",error);
                    }];
                }
            }
            else {
                [MBProgressHUDHelper showError:@"网络请求失败" complete:nil];
            }
        }];
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
