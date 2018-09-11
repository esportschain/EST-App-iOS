//
//  GameDetailVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/21.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "GameDetailVC.h"
#import "SeasonPickerView.h"
#import "MJRefresh.h"

@interface GameDetailVC ()<WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) SeasonPickerView *picker;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int countDown;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) BOOL isOpened;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *selectedId;

@property (nonatomic, strong) MJRefreshNormalHeader* refreshHeader;

@end

@implementation GameDetailVC

- (id)initWithURL:(NSString *)urlStr {
    
    self.urlStr = urlStr;
    self.selectedId = @"";
    
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
                
                layout.text = @"PUBG Stats";
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
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    self.refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(didTriggerPullDownRefresh)];
    self.refreshHeader.y = -self.refreshHeader.height;
    [self.webView.scrollView addSubview:self.refreshHeader];
    
    self.hud = [MBProgressHUDHelper showLoading:@""];
    
    //10秒计时器
    self.countDown = 10;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)onTimer {
    self.countDown--;
    if (self.countDown == 0) {
        [self.timer invalidate];
        self.timer = nil;
        
        if (!self.isOpened) {
            [self.hud hideAnimated:YES];
            [MBProgressHUDHelper showError:@"Connection Failed" complete:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didTriggerPullDownRefresh
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    self.hud = [MBProgressHUDHelper showLoading:@""];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.refreshHeader endRefreshing];
    [self.hud hideAnimated:YES];
    self.isOpened = YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if([navigationAction.request.URL.absoluteString isEqualToString:self.urlStr]) {//主页面加载内容
        decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
    } else {//截获页面里面的链接点击
        GameDetailVC *gameDetailVC = [[GameDetailVC alloc] initWithURL:navigationAction.request.URL.absoluteString];
        [self.navigationController pushViewController:gameDetailVC animated:YES];
        
        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
    }
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
    
    if ([method isEqualToString:@"callSelect"]) {
        self.type = [dic objectForKey:@"type"];
        NSString *arrStr = [dic objectForKey:@"arr"];
        NSData *jsonData = [arrStr dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        self.picker = [[SeasonPickerView alloc] initWithFrame:CGRectZero seasonArr:arr selectedId:self.selectedId];
        
        [self.picker showWithHandler:^(NSString *selectedId) {
            self.selectedId = selectedId;
            
            NSString *javascript = [NSString stringWithFormat:@"selectAfterAction('%@','%@');", self.type, selectedId];
            
            [self.webView evaluateJavaScript:javascript completionHandler:^(id _Nullable aaa, NSError * _Nullable error) {
                DLog(@"%@",error);
            }];
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
