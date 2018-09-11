//
//  PasswordVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/14.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "PasswordVC.h"
#import "ProfileVC.h"

@interface PasswordVC ()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UITextField *confirmTF;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation PasswordVC

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
                
                layout.text = @"Password";
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
        
        UILabel *passwordLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.belowOf = navBar;
            params.topMargin = 24;
            params.leftMargin = 14;
            
            layout.text = @"Set your password";
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
        
        self.nextBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = self.confirmTF;
            params.topMargin = 26;
            
            [layout setTitle:@"NEXT" forState:UIControlStateNormal];
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
                    ProfileVC *profileVC = [[ProfileVC alloc] init];
                    profileVC.loginVC = self.loginVC;
                    profileVC.emailStr = self.emailStr;
                    profileVC.registerKey = self.registerKey;
                    profileVC.password = self.passwordTF.text;
                    [self.navigationController pushViewController:profileVC animated:YES];
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
    
    [self.rootLayout requestLayout];
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGr {
    [self.passwordTF resignFirstResponder];
    [self.confirmTF resignFirstResponder];
}

- (void)textFieldDidChangeValue:(id)sender {
    if (![self.passwordTF.text isEqualToString:@""] && ![self.confirmTF.text isEqualToString:@""]) {
        self.nextBtn.backgroundColor = kColor31B4FF;
        self.nextBtn.enabled = YES;
    } else {
        self.nextBtn.backgroundColor = kColorC3CBCF;
        self.nextBtn.enabled = NO;
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
