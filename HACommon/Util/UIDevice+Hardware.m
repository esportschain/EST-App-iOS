//
//  UIDevice+Hardware.m
//  SFSdk
//
//  Created by Song Xiaofeng on 13-8-14.
//  Copyright (c) 2013年 xiaofeng Inc. All rights reserved.
//

#import "UIDevice+Hardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "LoadableCategory.h"
MAKE_CATEGORIES_LOADABLE(SFSdk_UIDevice_Hardware)

#define ALL_IPHONE_INFO(MARCO_NAME)                      \
MARCO_NAME(UIDeviceHardware_iPhone_1,        @"iPhone1,1",       @"iPhone 1G"    )\
MARCO_NAME(UIDeviceHardware_iPhone_3G,       @"iPhone1,2",       @"iPhone 3G"    )\
MARCO_NAME(UIDeviceHardware_iPhone_3GS,      @"iPhone2,1",       @"iPhone 3GS"   )\
MARCO_NAME(UIDeviceHardware_iPhone_4,        @"iPhone3,1",       @"iPhone 4"     )\
MARCO_NAME(UIDeviceHardware_iPhone_4,        @"iPhone3,2",       @"iPhone 4"     )\
MARCO_NAME(UIDeviceHardware_iPhone_4,        @"iPhone3,3",       @"iPhone 4"     )\
MARCO_NAME(UIDeviceHardware_iPhone_4S,       @"iPhone4,1",       @"iPhone 4S"    )\
MARCO_NAME(UIDeviceHardware_iPhone_5,        @"iPhone5,1",       @"iPhone 5"     )\
MARCO_NAME(UIDeviceHardware_iPhone_5,        @"iPhone5,2",       @"iPhone 5"     )\
MARCO_NAME(UIDeviceHardware_iPhone_5,        @"iPhone5,3",       @"iPhone 5C"    )\
MARCO_NAME(UIDeviceHardware_iPhone_5,        @"iPhone5,4",       @"iPhone 5C"    )\
MARCO_NAME(UIDeviceHardware_iPhone_5S,       @"iPhone6,1",       @"iPhone 5S"    )\
MARCO_NAME(UIDeviceHardware_iPhone_5S,       @"iPhone6,2",       @"iPhone 5S"    )\
MARCO_NAME(UIDeviceHardware_iPhone_6,        @"iPhone7,1",       @"iPhone 6"     )\
MARCO_NAME(UIDeviceHardware_iPhone_6PLUS,    @"iPhone7,2",       @"iPhone 6 PLUS")\
\
\
MARCO_NAME(UIDeviceHardware_iPod_Touch_1G,   @"iPod1,1",         @"iPod Touch 1G")\
MARCO_NAME(UIDeviceHardware_iPod_Touch_2G,   @"iPod2,1",         @"iPod Touch 2G")\
MARCO_NAME(UIDeviceHardware_iPod_Touch_3G,   @"iPod3,1",         @"iPod Touch 3G")\
MARCO_NAME(UIDeviceHardware_iPod_Touch_4G,   @"iPod4,1",         @"iPod Touch 4G")\
MARCO_NAME(UIDeviceHardware_iPod_Touch_5G,   @"iPod5,1",         @"iPod Touch 5G")\
\
\
MARCO_NAME(UIDeviceHardware_iPad_1,          @"iPad1,1",         @"iPad 1"       )\
MARCO_NAME(UIDeviceHardware_iPad_2,          @"iPad2,1",         @"iPad 2"       )\
MARCO_NAME(UIDeviceHardware_iPad_2,          @"iPad2,2",         @"iPad 2"       )\
MARCO_NAME(UIDeviceHardware_iPad_2,          @"iPad2,3",         @"iPad 2"       )\
MARCO_NAME(UIDeviceHardware_iPad_2,          @"iPad2,4",         @"iPad 2"       )\
MARCO_NAME(UIDeviceHardware_iPad_3,          @"iPad3,1",         @"iPad 3"       )\
MARCO_NAME(UIDeviceHardware_iPad_3,          @"iPad3,2",         @"iPad 3"       )\
MARCO_NAME(UIDeviceHardware_iPad_3,          @"iPad3,3",         @"iPad 3"       )\
MARCO_NAME(UIDeviceHardware_iPad_4,          @"iPad3,4",         @"iPad 4"       )\
MARCO_NAME(UIDeviceHardware_iPad_4,          @"iPad3,5",         @"iPad 4"       )\
MARCO_NAME(UIDeviceHardware_iPad_4,          @"iPad3,6",         @"iPad 4"       )\
MARCO_NAME(UIDeviceHardware_iPad_5,          @"iPad4,1",         @"iPad Air"     )\
MARCO_NAME(UIDeviceHardware_iPad_5,          @"iPad4,2",         @"iPad Air"     )\
MARCO_NAME(UIDeviceHardware_iPad_5,          @"iPad4,3",         @"iPad Air"     )\
\
\
MARCO_NAME(UIDeviceHardware_iPad_Mini_1,     @"iPad2,5",         @"iPad Mini"    )\
MARCO_NAME(UIDeviceHardware_iPad_Mini_1,     @"iPad2,6",         @"iPad Mini"    )\
MARCO_NAME(UIDeviceHardware_iPad_Mini_1,     @"iPad2,7",         @"iPad Mini"    )\
MARCO_NAME(UIDeviceHardware_iPad_Mini_2,     @"iPad4,4",         @"iPad Mini 2"  )\
MARCO_NAME(UIDeviceHardware_iPad_Mini_2,     @"iPad4,5",         @"iPad Mini 2"  )\


#define CHECK_NAME(ENUM,HARDWARE,NAME) \
if ([str isEqualToString:HARDWARE]) {return ENUM;}

@implementation UIDevice (Hardware)
+ (UIDeviceHardware) deviceHardware{
    NSString *str = [self hardwareModel];
    ALL_IPHONE_INFO(CHECK_NAME)
    
    return UIDeviceHardware_Unknow;
}

+ (NSString *) hardwareModel
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *hwString = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return hwString;
}

+ (NSString*)macAddress;
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}
@end
