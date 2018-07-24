//
//  AppDelegate.h
//  esports
//
//  Created by 焦龙 on 2018/6/11.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSInteger tableViewOffset;
@property (nonatomic, assign) NSInteger bottomOffset;

- (void)startOver;
- (void)loadMain;

@end

