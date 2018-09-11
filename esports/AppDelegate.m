//
//  AppDelegate.m
//  esports
//
//  Created by 焦龙 on 2018/6/11.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"
#import "MineVC.h"
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UINavigationController *rootNavigationController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = kColorWhite;
    [self.window makeKeyAndVisible];
    
    if (IS_IOS_11) {
        if (IS_IPHONE_X) {
            self.tableViewOffset = 88;
            self.bottomOffset = 32;
        } else {
            self.tableViewOffset = 64;
            self.bottomOffset = 0;
        }
    } else {
        self.tableViewOffset = 44;
        self.bottomOffset = 0;
    }
    
    // 创建工作目录
    devFS_createFolder([kPathRoot cStringUsingEncoding:NSUTF8StringEncoding]);
    devFS_createFolder([kPathCache cStringUsingEncoding:NSUTF8StringEncoding]);
    devFS_createFolder([kPathUrlCache cStringUsingEncoding:NSUTF8StringEncoding]);
    devFS_createFolder([kPathDownload cStringUsingEncoding:NSUTF8StringEncoding]);
    
    // 设置不要备份
    NSURL* rootPathUrl = [NSURL fileURLWithPath:kPathRoot];
    [rootPathUrl addSkipBackupAttribute];
    NSURL* cachePathUrl = [NSURL fileURLWithPath:kPathCache];
    [cachePathUrl addSkipBackupAttribute];
    NSURL* urlCachePathUrl = [NSURL fileURLWithPath:kPathUrlCache];
    [urlCachePathUrl addSkipBackupAttribute];
    NSURL* downloadPathUrl = [NSURL fileURLWithPath:kPathDownload];
    [downloadPathUrl addSkipBackupAttribute];
    
    [self startOver];
    
    [UMConfigure setLogEnabled:YES];
    [UMConfigure initWithAppkey:UMENG_APPKEY channel:@"App Store"];
    // Push's basic setting
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }else
        {
        }
    }];
    
    return YES;
}

- (void)startOver {
    self.rootNavigationController = [[UINavigationController alloc] init];
    self.window.rootViewController = self.rootNavigationController;
    [self.rootNavigationController setNavigationBarHidden:YES];
    
    if ([AccountManager sharedInstance].account.userId == NULL) {
        [AccountManager sharedInstance].account.userId = @"";
    }
    if ([AccountManager sharedInstance].account.token == NULL) {
        [AccountManager sharedInstance].account.token = @"";
    }
    
    if ([AccountManager sharedInstance].account.userId.integerValue <= 0) {
        LoginVC *loginVC = [[LoginVC alloc] init];
        [self.rootNavigationController pushViewController:loginVC animated:NO];

        [AccountManager sharedInstance].account.authKey = @"-1";
    } else {
        [self loadMain];
    }

    //设备唯一标识
    [AccountManager sharedInstance].account.idfv = [SvUDIDTools UDID];
    NSLog(@"idfv=%@", [AccountManager sharedInstance].account.idfv);
    
    [[AccountManager sharedInstance] saveAccountInfoToDisk];
    
    NSLog(@"uid=%@", [AccountManager sharedInstance].account.userId);
    NSLog(@"token=%@", [AccountManager sharedInstance].account.token);
    NSLog(@"authkey=%@", [AccountManager sharedInstance].account.authKey);
    NSLog(@"nickname=%@", [AccountManager sharedInstance].account.nickname);
    NSLog(@"avatar=%@", [AccountManager sharedInstance].account.avatar);
}

- (void)loadMain {
    MineVC *mineVC = [[MineVC alloc] init];
    [self.rootNavigationController pushViewController:mineVC animated:NO];
}

- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"deviceToken=%@", token);
    [AccountManager sharedInstance].account.deviceToken = token;
    [[AccountManager sharedInstance] saveAccountInfoToDisk];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    [AccountManager sharedInstance].account.deviceToken = @"0";
    [[AccountManager sharedInstance] saveAccountInfoToDisk];
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

//iOS10以下使用这个方法接收通知，
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage setAutoAlert:YES];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_REFRESH_AMOUNT" object:nil];
        
        //    self.userInfo = userInfo;
        //    //定制自定的的弹出框
        //    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        //    {
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"标题"
        //                                                            message:@"Test On ApplicationStateActive"
        //                                                           delegate:self
        //                                                  cancelButtonTitle:@"确定"
        //                                                  otherButtonTitles:nil];
        //
        //        [alertView show];
        //
        //    }
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //U-Push自带的弹出框
        [UMessage setAutoAlert:YES];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_REFRESH_AMOUNT" object:nil];
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_REFRESH_AMOUNT" object:nil];
    }else{
        //应用处于后台时的本地推送接受
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [UMessage setBadgeClear:YES];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
