//
//  BaseViewController.m
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

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIApplication.h>

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        DLog(@"ViewController init: %@", NSStringFromClass([self class]));
        
        self.hideNavigationBar = NO;
        self.hidesBottomBarWhenPushed = YES;
        
        if ([self conformsToProtocol:@protocol(BaseViewControllerKeyboardChangedDelegate)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:kRootViewColor];
}

- (void)dealloc
{
    DLog(@"ViewController dealloc: %@", NSStringFromClass([self class]));
    
    if ([self conformsToProtocol:@protocol(BaseViewControllerKeyboardChangedDelegate)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.hideNavigationBar animated:animated];
}

#pragma mark - private
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect frame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect bounds = self.navigationController.view.bounds;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            bounds.size.height -= frame.size.height;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            bounds.origin.y += frame.size.height;
            bounds.size.height -= frame.size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            bounds.size.width -= frame.size.width;
            break;
        case UIInterfaceOrientationLandscapeRight:
            bounds.origin.x += frame.size.width;
            bounds.size.width -= frame.size.width;
            break;
        default:
            break;
    }
    
    if ([self conformsToProtocol:@protocol(BaseViewControllerKeyboardChangedDelegate)]) {
        id<BaseViewControllerKeyboardChangedDelegate> delegate = (id<BaseViewControllerKeyboardChangedDelegate>)self;
        if ([delegate respondsToSelector:@selector(onResizeView:duration:isKeyboardShow:)]) {
            [delegate onResizeView:bounds.size duration:duration isKeyboardShow:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self conformsToProtocol:@protocol(BaseViewControllerKeyboardChangedDelegate)]) {
        id<BaseViewControllerKeyboardChangedDelegate> delegate = (id<BaseViewControllerKeyboardChangedDelegate>)self;
        if ([delegate respondsToSelector:@selector(onResizeView:duration:isKeyboardShow:)]) {
            [delegate onResizeView:self.navigationController.view.bounds.size duration:[[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] isKeyboardShow:NO];
        }
    }
}

@end
