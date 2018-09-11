//
//  ProfileVC.m
//  esports
//
//  Created by 焦龙 on 2018/6/14.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UIImageView *avatarIV;
@property (nonatomic, strong) UITextField *nicknameTF;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) NSString *idAvatarImagePath;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation ProfileVC

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
                
                layout.text = @"Profile";
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
        
        self.avatarIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
            
            params.width = 80;
            params.height = 80;
            params.centerHorizontal = YES;
            params.belowOf = navBar;
            params.topMargin = 32;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 40.0;
            layout.layer.masksToBounds = YES;
            layout.contentMode = UIViewContentModeScaleAspectFill;
        }];
        
        [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = 80;
            params.height = 80;
            params.centerHorizontal = YES;
            params.belowOf = navBar;
            params.topMargin = 32;
            
            [layout bk_addEventHandler:^(id sender) {
                [self modifyAvatar];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
        
        UILabel *nicknameLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
            
            params.width = WRAP_CONTENT;
            params.height = WRAP_CONTENT;
            params.belowOf = self.avatarIV;
            params.topMargin = 38;
            params.leftMargin = 14;
            
            layout.text = @"Nickname";
            layout.textColor = kColorBlack;
            layout.font = kNormalFont(16);
        }];
        
        self.nicknameTF = [UITextField build:layout config:^(RelativeLayoutParams *params, UITextField *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = nicknameLbl;
            params.topMargin = 12;
            
            layout.backgroundColor = kColorECF1F4;
            layout.layer.cornerRadius = 4.0;
            layout.font = kNormalFont(16);
            layout.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
            layout.leftViewMode = UITextFieldViewModeAlways;
            [layout addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        self.finishBtn = [UIButton build:layout config:^(RelativeLayoutParams *params, UIButton *layout) {
            
            params.width = kDeviceWidth - 28;
            params.height = 48;
            params.centerHorizontal = YES;
            params.belowOf = self.nicknameTF;
            params.topMargin = 26;
            
            [layout setTitle:@"Finish" forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateNormal];
            [layout setTitleColor:kColorWhite forState:UIControlStateHighlighted];
            layout.backgroundColor = kColorC3CBCF;
            layout.enabled = NO;
            [layout.titleLabel setFont:kNormalFont(16)];
            layout.layer.cornerRadius = 4.0;
            [layout bk_addEventHandler:^(id sender) {
                [self goRegister];
            } forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
    
    [self.rootLayout requestLayout];
}

- (void)goRegister {
    MBProgressHUD *hud = [MBProgressHUDHelper showLoading:@""];
    
    //非公共参数字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [paramDic setObject:@"App" forKey:@"d"];
    [paramDic setObject:@"Member" forKey:@"c"];
    [paramDic setObject:@"register" forKey:@"m"];
    
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
    [paramDic setObject:self.nicknameTF.text forKey:@"nickname"];
    [paramDic setObject:self.registerKey forKey:@"key"];
    
    NSString *pwdMD5 = [HAStringUtil md5:self.password];
    [paramDic setObject:pwdMD5 forKey:@"new_pwd"];
    [paramDic setObject:pwdMD5 forKey:@"rnew_pwd"];
    
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
    [task.request.params setValue:self.nicknameTF.text forKey:@"nickname"];
    [task.request.params setValue:self.registerKey forKey:@"key"];
    [task.request.params setValue:pwdMD5 forKey:@"new_pwd"];
    [task.request.params setValue:pwdMD5 forKey:@"rnew_pwd"];
    
    if (self.isSelected) {
        HAFormPostData *imageData = [[HAFormPostData alloc] init];
        imageData.fileName = @"idAvatarImage.jpg";
        imageData.contentType = @"image/jpg";
        imageData.data = UIImageJPEGRepresentation(self.avatarIV.image, .7);
        [task.request.params setValue:imageData forKey:@"avatar"];
    }
    
    task.request.method = HttpMethodPost;
    
    [[HttpRequest sharedInstance] execute:task complete:^(HAHttpTask *task) {
        [hud hideAnimated:YES];
        
        if (task.status == HttpTaskStatusSucceeded) {
            HttpResult* result = (HttpResult*)task.result;
            if (result.code == HTTP_RESULT_SUCCESS) {
                [MBProgressHUDHelper showSuccess:@"Register successfully, please login." complete:nil];
                [self.navigationController popToViewController:self.loginVC animated:YES];
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

- (void)modifyAvatar{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Select From Album", nil];
    __weak typeof(self) weakSelf = self;
    [sheet bk_setHandler:^{
        // 跳转到相机
        weakSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [weakSelf presentViewController:weakSelf.imagePickerController animated:YES completion:^{}];
    } forButtonAtIndex:0];
    [sheet bk_setHandler:^{
        // 跳转到相册页面
        weakSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakSelf presentViewController:weakSelf.imagePickerController animated:YES completion:^{}];
    } forButtonAtIndex:1];
    [sheet showInView:self.view];
}

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self saveImage:image withName:@"idAvatarImage.jpg"];
    self.idAvatarImagePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"idAvatarImage.jpg"];
    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:self.idAvatarImagePath];
    NSData * imageData = UIImageJPEGRepresentation(image2,1);
    NSInteger length = [imageData length]/1024;
    NSLog(@"pic length:%ldkb",(long)length);
    [self.avatarIV setImage:image];
    self.isSelected = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGr {
    [self.nicknameTF resignFirstResponder];
}

- (void)textFieldDidChangeValue:(id)sender {
    if (![((UITextField *)sender).text isEqualToString:@""]) {
        self.finishBtn.backgroundColor = kColor31B4FF;
        self.finishBtn.enabled = YES;
    } else {
        self.finishBtn.backgroundColor = kColorC3CBCF;
        self.finishBtn.enabled = NO;
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
