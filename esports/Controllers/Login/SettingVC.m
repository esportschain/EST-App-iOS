//
//  SettingVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/25.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "SettingVC.h"
#import "ModifyAvatarVC.h"
#import "ModifyPwdVC.h"

@interface SettingVC ()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIImageView *avatarIV;

@end

@implementation SettingVC

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
        
        UIView *navBar = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
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
                
                layout.text = @"Settings";
                layout.textColor = kColorBlack;
                layout.font = kNormalFont(16);
            }];
            
            [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 1;
                params.alignParentBottom = YES;
                
                [layout setBackgroundColor:kColorF0F0F0];
            }];
        }];
        
        self.mainScrollView = [UIScrollView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIScrollView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = kDeviceHeight - theAppDelegate.tableViewOffset - theAppDelegate.bottomOffset;
            params.belowOf = navBar;
            
            layout.layoutContainer.limitChild = false;
            
            UIButton *avatarBtn = [UIButton build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 60;
                
                layout.backgroundColor = kColorWhite;
                [layout bk_addEventHandler:^(id sender) {
                    ModifyAvatarVC *modifyAvatarVC = [[ModifyAvatarVC alloc] init];
                    [self.navigationController pushViewController:modifyAvatarVC animated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
                
                [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.centerVertical = YES;
                    params.leftMargin = 15;
                    
                    layout.text = @"Profile";
                    layout.textColor = kColorBlack;
                    layout.font = kNormalFont(16);
                }];
                
                self.avatarIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                    
                    params.width = 40;
                    params.height = 40;
                    params.centerVertical = YES;
                    params.alignParentRight = YES;
                    params.rightMargin = 38;
                    
                    [layout setContentMode:UIViewContentModeScaleAspectFill];
                    layout.layer.masksToBounds = YES;
                    layout.layer.cornerRadius = 20.0;
                }];
                
                [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.alignParentRight = YES;
                    params.centerVertical = YES;
                    params.rightMargin = 22;
                    
                    [layout setImage:Image(@"icon_right")];
                }];
                
                [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                    
                    params.width = MATCH_PARENT;
                    params.height = 1;
                    params.alignParentBottom = YES;
                    
                    [layout setBackgroundColor:kColorF0F0F0];
                }];
            }];
            
            UIButton *pwdBtn = [UIButton build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 60;
                params.belowOf = avatarBtn;
                
                layout.backgroundColor = kColorWhite;
                [layout bk_addEventHandler:^(id sender) {
                    ModifyPwdVC *modifyPwdVC = [[ModifyPwdVC alloc] init];
                    [self.navigationController pushViewController:modifyPwdVC animated:YES];                } forControlEvents:UIControlEventTouchUpInside];
                
                [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.centerVertical = YES;
                    params.leftMargin = 15;
                    
                    layout.text = @"Password";
                    layout.textColor = kColorBlack;
                    layout.font = kNormalFont(16);
                }];
                
                [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.alignParentRight = YES;
                    params.centerVertical = YES;
                    params.rightMargin = 22;
                    
                    [layout setImage:Image(@"icon_right")];
                }];
                
                [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                    
                    params.width = MATCH_PARENT;
                    params.height = 1;
                    params.alignParentBottom = YES;
                    
                    [layout setBackgroundColor:kColorF0F0F0];
                }];
            }];
            
            [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
                
                params.width = kDeviceWidth - 28;
                params.height = 48;
                params.centerHorizontal = YES;
                params.belowOf = pwdBtn;
                params.topMargin = 26;
                
                [layout setTitle:@"Logout" forState:UIControlStateNormal];
                [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
                [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
                layout.backgroundColor = kColor31B4FF;
                [layout.titleLabel setFont:kNormalFont(16)];
                layout.layer.cornerRadius = 4.0;
                [layout bk_addEventHandler:^(id sender) {
                    [self logout];
                } forControlEvents:UIControlEventTouchUpInside];
            }];
        }];
    }];
    
    [self.rootLayout requestLayout];
    
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, self.mainScrollView.height + 1)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    [self.avatarIV sd_setImageWithURL:[NSURL URLWithString:[AccountManager sharedInstance].account.avatar] placeholderImage:Image(@"placeholder_avatar")];
}

- (void)logout {
    [AccountManager sharedInstance].account.userId = @"";
    [AccountManager sharedInstance].account.token = @"";
    [AccountManager sharedInstance].account.authKey = @"-1";
    [AccountManager sharedInstance].account.nickname = @"";
    [AccountManager sharedInstance].account.avatar = @"";
    [[AccountManager sharedInstance] saveAccountInfoToDisk];
    [theAppDelegate startOver];
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
