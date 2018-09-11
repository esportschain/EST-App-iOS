//
//  MineVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/11.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "MineVC.h"
#import "GameListModel.h"
#import "GameListCell.h"
#import "ThirdLoginVC.h"
#import "WalletVC.h"
#import "GameDetailVC.h"
#import "GameBindVC.h"
#import "SettingVC.h"

@interface MineVC ()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *avatarIV;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *amountLbl;
@property (nonatomic, strong) UIView *addedView;
@property (nonatomic, strong) UIImageView *walletIV;
@property (nonatomic, strong) UIButton *walletBtn;

@property (nonatomic, assign) float originHeight;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) HADataWrapper *popListWrapper;
@property (nonatomic, assign) int popIndex;
@property (nonatomic, strong) NSString *popId;

@end

@implementation MineVC

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
        params.height = WRAP_CONTENT;
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
                params.alignParentRight = YES;
                
                [layout setImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
                [layout bk_addEventHandler:^(id sender) {
                    SettingVC *settingVC = [[SettingVC alloc] init];
                    [self.navigationController pushViewController:settingVC animated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
            }];
        }];
    }];
    
    [self.rootLayout requestLayout];
    
    self.tableView.frame = CGRectMake(0, theAppDelegate.tableViewOffset, kScreenWidth, kScreenHeight - theAppDelegate.tableViewOffset - theAppDelegate.bottomOffset);
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 198)];
    self.originHeight = self.tableView.tableHeaderView.height;
    
    self.headerView = [UIView build:self.tableView.tableHeaderView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
        
        params.width = MATCH_PARENT;
        params.height = MATCH_PARENT;
        
        UIView *avatarView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = 140;
            
            layout.backgroundColor = kColorWhite;
            
            self.avatarIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                
                params.width = 56;
                params.height = 56;
                params.centerHorizontal = YES;
                params.topMargin = 25;
                
                [layout setContentMode:UIViewContentModeScaleAspectFill];
                layout.layer.masksToBounds = YES;
                layout.layer.cornerRadius = 28.0;
            }];
            
            self.nameLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerHorizontal = YES;
                params.belowOf = self.avatarIV;
                params.topMargin = 14;
                
                layout.textColor = kColorBlack;
                layout.font = kBoldFont(16);
            }];
        }];
        
        UIView *walletView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = 50;
            params.belowOf = avatarView;
            params.topMargin = 8;
            
            layout.backgroundColor = kColorWhite;
            
            [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerVertical = YES;
                params.leftMargin = 17;
                
                layout.image = Image(@"icon_wallet");
            }];
            
            [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerVertical = YES;
                params.leftMargin = 50;
                
                layout.text = @"EST Wallet";
                layout.textColor = kColorBlack;
                layout.font = kNormalFont(16);
            }];
            
            self.amountLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerVertical = YES;
                params.alignParentRight = YES;
                params.rightMargin = 38;
                
                layout.textColor = kColor31B4FF;
                layout.font = kNormalFont(16);
            }];
            
            self.walletIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerVertical = YES;
                params.alignParentRight = YES;
                params.rightMargin = 18;
                
                layout.image = Image(@"icon_right");
            }];
            
            self.walletBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = MATCH_PARENT;
                params.height = MATCH_PARENT;
                
                [layout bk_addEventHandler:^(id sender) {
                    WalletVC *walletVC = [[WalletVC alloc] initWithAmount:self.amount];
                    [self.navigationController pushViewController:walletVC animated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
            }];
        }];
        
        self.addedView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = WRAP_CONTENT;
            params.belowOf = walletView;
        }];
    }];
    
    [self.headerView requestLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllData) name:@"NOTI_LOGIN_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllData) name:@"NOTI_BINDGAME_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllData) name:@"NOTI_REFRESH_AMOUNT" object:nil];
}

- (void)refreshAllData {
    [self didTriggerPullDownRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.avatarIV sd_setImageWithURL:[NSURL URLWithString:[AccountManager sharedInstance].account.avatar] placeholderImage:Image(@"placeholder_avatar")];
}

#pragma mark - HATableViewControllerConfig
- (HAListModel*)requireListModel
{
    GameListModel* listModel = [[GameListModel alloc] init];
    return listModel;
}

- (Class<HATableViewCell>)requireCellClass
{
    return [GameListCell class];
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
        HADataWrapper *userWrapper = [result.data dataWrapperForKey:@"user"];
        [self.avatarIV sd_setImageWithURL:[NSURL URLWithString:[userWrapper stringForKey:@"avatar"]] placeholderImage:Image(@"placeholder_avatar")];
        self.nameLbl.text = [userWrapper stringForKey:@"nickname"];
        self.amount = [userWrapper stringForKey:@"money"];
        self.amountLbl.text = self.amount;
        
        for (id tmpView in [self.addedView subviews]) {
            [tmpView removeFromSuperview];
        }
        self.tableView.tableHeaderView.height = self.originHeight;
        
        int status = [userWrapper intForKey:@"status"];
        if (status == 1) {
            self.walletIV.hidden = YES;
            self.walletBtn.enabled = NO;
            
            self.tableView.tableHeaderView.height += 132;
            
            UILabel *statusLbl = [UILabel build:self.addedView config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 20;
                params.leftMargin = 15;
                
                layout.text = @"My Game Statistics";
                layout.textColor = kColorLightGray;
                layout.font = kNormalFont(14);
            }];
            
            [UIView build:self.addedView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 86;
                params.belowOf = statusLbl;
                
                layout.backgroundColor = kColorWhite;
                
                UIImageView *logoIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.topMargin = 13;
                    params.leftMargin = 16;
                    
                    layout.image = Image(@"btn_steam");
                }];
                
                [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.topMargin = 10;
                    params.rightOf = logoIV;
                    params.leftMargin = 10;
                    
                    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:@"Login with your Steam Account"];
                    [tncString addAttribute:NSUnderlineStyleAttributeName
                                      value:@(NSUnderlineStyleSingle)
                                      range:(NSRange){0,[tncString length]}];
                    //此时如果设置字体颜色要这样
                    [tncString addAttribute:NSForegroundColorAttributeName value:kColor31B4FF range:NSMakeRange(0,[tncString length])];
                    //设置下划线颜色
                    [tncString addAttribute:NSUnderlineColorAttributeName value:kColor31B4FF range:(NSRange){0,[tncString length]}];
                    [layout setAttributedTitle:tncString forState:UIControlStateNormal];
                    [layout.titleLabel setFont:kNormalFont(16)];
                }];
                
                [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.belowOf = logoIV;
                    params.topMargin = 10;
                    params.leftMargin = 50;
                    
                    layout.text = @"Get your game stats and EST bonus";
                    layout.textColor = kColorLightGray;
                    layout.font = kNormalFont(14);
                }];
                
                [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                    
                    params.width = MATCH_PARENT;
                    params.height = MATCH_PARENT;
                    
                    [layout bk_addEventHandler:^(id sender) {
                        [self loginWithType:1];
                    } forControlEvents:UIControlEventTouchUpInside];
                }];
            }];
        } else if (status == 2) {
            self.walletIV.hidden = YES;
            self.walletBtn.enabled = NO;
            
            self.tableView.tableHeaderView.height += 190;
            
            [UIView build:self.addedView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 15;
                params.bottomMargin = 15;
                params.leftMargin = 15;
                params.rightMargin = 15;
                
                layout.backgroundColor = kColorEDDADA;
                layout.layer.borderColor = [kColorE5A3A4 CGColor];
                layout.layer.borderWidth = 1.0;
                layout.layer.cornerRadius = 4.0;
                
                [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = MATCH_PARENT;
                    params.height = WRAP_CONTENT;
                    params.topMargin = 10;
                    params.leftMargin = 10;
                    params.rightMargin = 10;
                    params.bottomMargin = 10;
                    
                    layout.textColor = kColorDE5353;
                    layout.font = kNormalFont(14);
                    layout.numberOfLines = 0;
                    layout.text = [userWrapper stringForKey:@"msg"];
                }];
            }];
        } else if (status == 3) {
            self.walletIV.hidden = NO;
            self.walletBtn.enabled = YES;
            
            self.tableView.tableHeaderView.height += 46;
            
            [UILabel build:self.addedView config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 20;
                params.leftMargin = 15;
                
                layout.text = @"My Game Statistics";
                layout.textColor = kColorLightGray;
                layout.font = kNormalFont(14);
            }];
            
//            [UILabel build:self.footerView config:^(RelativeLayoutParams *params, UILabel *layout) {
//
//                params.width = MATCH_PARENT;
//                params.height = WRAP_CONTENT;
//                params.topMargin = 10;
//                params.leftMargin = 10;
//                params.rightMargin = 10;
//                params.bottomMargin = 10;
//
//                layout.textColor = kColorBlack;
//                layout.font = kNormalFont(14);
//                layout.numberOfLines = 0;
//                layout.text = @"Mining Instruction\nEvery game stats you played today(0：00-24:00) will be calculate to a HashRate according to EST's algorithm, and these HashRates will be used to mine EST at 1am the next morning. HashRates of the day before yesterday are useless.";
//            }];
        }
        
        [self.headerView requestLayout];
        
        self.popListWrapper = [userWrapper dataWrapperForKey:@"popup"];
        self.popIndex = 0;
        [self beginPop];
    }
}

- (void)beginPop {
    if ([self.popListWrapper count] && [self.popListWrapper count] >= self.popIndex + 1) {
        HADataWrapper *popWrapper = [self.popListWrapper dataWrapperForIndex:self.popIndex];
        self.popId = [popWrapper stringForKey:@"pid"];
        int type = [popWrapper intForKey:@"type"];
        if (type == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[popWrapper stringForKey:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //非公共参数字典
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
        [paramDic setObject:@"App" forKey:@"d"];
        [paramDic setObject:@"Member" forKey:@"c"];
        [paramDic setObject:@"readMsg" forKey:@"m"];
        [paramDic setObject:self.popId forKey:@"pid"];
        
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
        
        HAHttpTask* task = [[HttpRequest sharedInstance] makeTask:self path:[NSString stringWithFormat:@"%@_param=%@&sig=%@", getStr, [HAURLUtil urlEncode:paramStr], sigMD5_2]];
        
        [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
            if (task.status == HttpTaskStatusSucceeded) {
                HttpResult* result = (HttpResult*)task.result;
                if (result.code == HTTP_RESULT_SUCCESS) {
                    self.popIndex ++;
                    [self beginPop];
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

#pragma mark - HATableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath model:(HAModel*)model {
    GameListItemModel *itemModel = (GameListItemModel *)model;
    
    if (itemModel.accountStatus == 1) {
        //非公共参数字典
        NSMutableDictionary *paramDic = itemModel.uriDic;
        
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
        
        GameDetailVC *gameDetailVC = [[GameDetailVC alloc] initWithURL:MAIN_API_URL(pathStr)];
        [self.navigationController pushViewController:gameDetailVC animated:YES];
    } else if (itemModel.accountStatus == 2 || itemModel.accountStatus == 4) {
        //非公共参数字典
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
        [paramDic setObject:@"App" forKey:@"d"];
        [paramDic setObject:@"Member" forKey:@"c"];
        [paramDic setObject:@"bindAccountTpl" forKey:@"m"];
        [paramDic setObject:itemModel.gameType forKey:@"gametype"];
        
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
        
        GameBindVC *gameBindVC = [[GameBindVC alloc] initWithURL:MAIN_API_URL(pathStr)];
        [self.navigationController pushViewController:gameBindVC animated:YES];
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
