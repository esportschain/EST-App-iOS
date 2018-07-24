//
//  ThirdLoginVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/19.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "ThirdLoginVC.h"

@interface ThirdLoginVC ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ThirdLoginVC

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
                
                layout.text = @"Verify";
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
    
    if ([method isEqualToString:@"callThirdLogin"]) {
        NSString *rst = [dic objectForKey:@"rst"];
        NSData *jsonData = [rst dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *rstDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dataDic = [rstDic objectForKey:@"data"];
        [self loginWithParams:dataDic];
    }
}

- (void)loginWithParams:(NSDictionary *)tempDic {
    if (![tempDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSLog(@"uid=%@", [tempDic objectForKey:@"uid"]);
    NSLog(@"token=%@", [tempDic objectForKey:@"token"]);
    NSLog(@"authkey=%@", [tempDic objectForKey:@"authkey"]);
    NSLog(@"nickname=%@", [tempDic objectForKey:@"nickname"]);
    NSLog(@"avatar=%@", [tempDic objectForKey:@"avatar"]);
    
    [AccountManager sharedInstance].account.userId = [tempDic objectForKey:@"uid"];
    [AccountManager sharedInstance].account.token = [tempDic objectForKey:@"token"];
    [AccountManager sharedInstance].account.authKey = [tempDic objectForKey:@"authkey"];
    [AccountManager sharedInstance].account.nickname = [tempDic objectForKey:@"nickname"];
    [AccountManager sharedInstance].account.avatar = [tempDic objectForKey:@"avatar"];
    [[AccountManager sharedInstance] saveAccountInfoToDisk];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_LOGIN_SUCCESS" object:nil];
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
