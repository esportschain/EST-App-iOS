//
//  UIDevice+Hardware.h
//  SFSdk
//
//  Created by Song Xiaofeng on 13-8-14.
//  Copyright (c) 2013年 xiaofeng Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, UIDeviceHardware)
{
    // iPhone
    UIDeviceHardware_iPhone_1           = 10,// 412 / 620
    UIDeviceHardware_iPhone_3G          = 20,// 412 / 620
    UIDeviceHardware_iPhone_3GS         = 30,// 600 / 833
    UIDeviceHardware_iPhone_4           = 40,// A4 800
    UIDeviceHardware_iPhone_4S          = 50,// A5 800 /1G
    UIDeviceHardware_iPhone_5           = 60,// 1.3 A6
    UIDeviceHardware_iPhone_5C          = 61,// 1.3 A6
    UIDeviceHardware_iPhone_5S          = 70,// 1.3 A7
    UIDeviceHardware_iPhone_6           = 80,//
    UIDeviceHardware_iPhone_6PLUS       = 90,
    
    // iPod
    UIDeviceHardware_iPod_Touch_1G      = 21,// 412 / 620
    UIDeviceHardware_iPod_Touch_2G      = 22,// 533 / 620
    UIDeviceHardware_iPod_Touch_3G      = 31,// 600 / 833
    UIDeviceHardware_iPod_Touch_4G      = 42, // A4 800
    UIDeviceHardware_iPod_Touch_5G      = 53, // A5 800Hz/1GHz
    
    // iPad
    UIDeviceHardware_iPad_1             = 41, // A4
    UIDeviceHardware_iPad_2             = 52, // A5
    UIDeviceHardware_iPad_3             = 55, // A5X
    UIDeviceHardware_iPad_4             = 65, // A6X
    UIDeviceHardware_iPad_5             = 71, // A7
    UIDeviceHardware_iPad_Air = UIDeviceHardware_iPad_5,
    
    // iPad mini
    UIDeviceHardware_iPad_Mini_1        = 51,
    UIDeviceHardware_iPad_Mini_2        = 72,
    UIDeviceHardware_iPad_Mini_Retina = UIDeviceHardware_iPad_Mini_2,
    
    // unknow or Simulator max
    UIDeviceHardware_Unknow  = 10000    ,
};

@interface UIDevice (Hardware)

+ (UIDeviceHardware)deviceHardware;

+ (NSString*)hardwareModel;

+ (NSString*)macAddress;
@end
