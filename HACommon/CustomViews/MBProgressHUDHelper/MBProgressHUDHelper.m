//
//  MBProgressHUDHelper.m
//  aimdev
//
//  Created by dongjianbo on 15-1-4.
//  Copyright 2015 www.aimdev.cn
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "MBProgressHUDHelper.h"

@implementation MBProgressHUDHelper

+ (void)showSuccess:(NSString*)success complete:(MBProgressHUDCompletionBlock)complete
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = success;
    hud.completionBlock = complete;
    [hud hideAnimated:YES afterDelay:1.5];
}

+ (void)showError:(NSString*)error complete:(MBProgressHUDCompletionBlock)complete
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = error;
    hud.completionBlock = complete;
    [hud hideAnimated:YES afterDelay:1.5];
}

+ (void)showError:(NSString*)error withDetailText:(NSString*)detailText complete:(MBProgressHUDCompletionBlock)complete
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = detailText;
    hud.completionBlock = complete;
    [hud hideAnimated:YES afterDelay:1.5];
}

+ (MBProgressHUD*)showLoading:(NSString*)loading
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = loading;
    return hud;
}

+ (MBProgressHUD*)showLoading:(NSString*)loading inView:(UIView*)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = loading;
    return hud;
}

@end
