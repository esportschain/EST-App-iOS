//
//  WalletVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/21.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "WalletVC.h"
#import "VerifyAccountVC.h"
#import "TradeListModel.h"
#import "TradeListCell.h"
#import "TradeView.h"

@interface WalletVC ()

@property (nonatomic, strong) NSString *amount;

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) TradeView *tradeView;
@property (nonatomic, strong) NSString *addStr;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *moneyLbl;

@end

@implementation WalletVC

- (id)initWithAmount:(NSString *)amount {
    
    self.amount = amount;
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.hideNavigationBar = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rootLayout = [UIView build:self.view container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
        
        params.width = MATCH_PARENT;
        params.height = MATCH_PARENT;
        params.topMargin = IS_IOS_7? 0:64;
        
        [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            if (IS_IPHONE_X) {
                params.height = 88;
            } else {
                params.height = 64;
            }
            
            layout.backgroundColor = kColorWhite;
            
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
                
                layout.text = @"EST Wallet";
                layout.textColor = kColorBlack;
                layout.font = kNormalFont(16);
            }];
        }];
        
        [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = MATCH_PARENT;
            params.height = 50;
            params.alignParentBottom = YES;
            params.bottomMargin = theAppDelegate.bottomOffset;
            
            [layout setTitle:@"Withdraw EST to my ETH Wallet" forState:UIControlStateNormal];
            [layout setTitleColor:kColor31B4FF forState:UIControlStateNormal];
            [layout setTitleColor:kColor31B4FF forState:UIControlStateHighlighted];
            layout.backgroundColor = kColorWhite;
            [layout.titleLabel setFont:kNormalFont(16)];
            [layout bk_addEventHandler:^(id sender) {
                if ([self.amount floatValue] < 30.0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your EST amount is less than 30, so you can't withdraw EST now. You can play more games to get more EST." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    self.tradeView = [[TradeView alloc] initWithFrame:CGRectZero amount:self.amount];
                    
                    [self.tradeView showWithHandler:^(NSString *addStr) {
                        [self putForward:addStr type:@"1"];
                        self.addStr = addStr;
                    }];
                }
                
            } forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
    
    [self.rootLayout requestLayout];
    
    self.tableView.frame = CGRectMake(0, theAppDelegate.tableViewOffset, kScreenWidth, kScreenHeight - theAppDelegate.tableViewOffset - theAppDelegate.bottomOffset - 50);
    [self.view bringSubviewToFront:self.tableView];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 166)];
    
    self.headerView = [UIView build:self.tableView.tableHeaderView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
        
        params.width = MATCH_PARENT;
        params.height = MATCH_PARENT;
        
        layout.backgroundColor = kColorWhite;
        
        [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = 100;
            params.topMargin = 2;
            params.leftMargin = 14;
            params.rightMargin = 14;
            
            layout.backgroundColor = kColor31B4FF;
            layout.layer.cornerRadius = 8;
            
            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 15;
                params.leftMargin = 22;
                
                layout.text = @"MY EST";
                layout.textColor = kColorWhite;
                layout.font = kBoldFont(14);
            }];
            
            self.moneyLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerHorizontal = YES;
                params.centerVertical = YES;
                
                layout.textColor = kColorWhite;
                layout.font = kNormalFont(32);
            }];
        }];
        
        [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.alignParentBottom = YES;
            params.bottomMargin = 14;
            params.leftMargin = 14;
            
            layout.text = @"Transcations";
            layout.textColor = kColorBlack;
            layout.font = kBoldFont(16);
        }];
        
        [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = 1;
            params.alignParentBottom = YES;
            params.leftMargin = 14;
            params.rightMargin = 14;
            
            layout.backgroundColor = kColorF0F0F0;
        }];
    }];
    
    [self.headerView requestLayout];
}

#pragma mark - HATableViewControllerConfig
- (HAListModel*)requireListModel
{
    TradeListModel* listModel = [[TradeListModel alloc] init];
    return listModel;
}

- (Class<HATableViewCell>)requireCellClass
{
    return [TradeListCell class];
}

- (HATableViewAdapter*)requireAdapter
{
    return [super requireAdapter];
}

- (MJRefreshHeader*)requireRefreshHeader
{
    return [super requireRefreshHeader];
}

- (MJRefreshFooter*)requireRefreshFooter
{
    return [super requireRefreshFooter];
}

- (RefreshIndicator*)requireRefreshIndicator
{
    return [super requireRefreshIndicator];
}

#pragma mark - HAHttpTaskSucceededFilter
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    [super onHAHttpTaskSucceededFilterExecute:task];
    
    HttpResult* result = (HttpResult*)task.result;
    if (result.code == HTTP_RESULT_SUCCESS) {
        self.moneyLbl.text = [result.data stringForKey:@"money"];
        [self.headerView requestLayout];
    }
}

- (void)putForward:(NSString *)addStr type:(NSString *)type {
    MBProgressHUD *hud = [MBProgressHUDHelper showLoading:@""];
    
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"putForward" forKey:@"m"];
    
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
    [paramDic setObject:addStr forKey:@"address"];
    [paramDic setObject:type forKey:@"type"];
    
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
    [task.request.params setValue:addStr forKey:@"address"];
    [task.request.params setValue:type forKey:@"type"];
    task.request.method = HttpMethodPost;
    
    [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
        [hud hideAnimated:YES];
        
        if (task.status == HttpTaskStatusSucceeded) {
            HttpResult* result = (HttpResult*)task.result;
            if (result.code == HTTP_RESULT_SUCCESS) {
                if ([result.data intForKey:@"status"] == 3) {
                    VerifyAccountVC *verifyAccountVC = [[VerifyAccountVC alloc] initWithBindId:[result.data stringForKey:@"bindid"]];
                    verifyAccountVC.walletVC = self;
                    [self.navigationController pushViewController:verifyAccountVC animated:YES];
                } else {
                    if ([type isEqualToString:@"1"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[result.data stringForKey:@"message"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your withdraw request is under processing, once it complete, we will send you a App notification." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self putForward:self.addStr type:@"2"];
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
