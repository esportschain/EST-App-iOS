//
//  esportsConst.h
//  esports


//

#ifndef esportsConst_h
#define esportsConst_h

#define MAIN_HOST           @"dev.esportschain.org"    /*www.esportschain.com*/
#define API_ACTION          @"/app.php?"
#define MAIN_API_URL(path)  [NSString stringWithFormat:@"https://%@%@%@", MAIN_HOST, API_ACTION, path]

#define PUBLIC_KEY          @" "
#define UMENG_APPKEY        @" "

#define theAppDelegate      ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define kDeviceWidth        [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight       [UIScreen mainScreen].bounds.size.height

#define RunTimeSysVersion   ([[UIDevice currentDevice].systemVersion floatValue])

#define IS_IOS_7            (RunTimeSysVersion >= 7.0f)
#define IS_IOS_11           (RunTimeSysVersion >= 11.0f)

#define IS_SCREEN_SMALL     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

#define IS_SCREEN_4INCH     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IPHONE_6         ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )667 ) < DBL_EPSILON )

#define IS_IPHONE_6PLUS     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )736 ) < DBL_EPSILON )

#define IS_IPHONE_X         ((double)[[UIScreen mainScreen] bounds].size.height > (double)736)

#define Image(image)        [UIImage imageNamed:(image)]


#define kColorWhite         [UIColor whiteColor]
#define kColorBlack         [UIColor blackColor]
#define kColorDarkGray      [UIColor darkGrayColor]
#define kColorLightGray     [UIColor lightGrayColor]
#define kColorGray          [UIColor grayColor]
#define kColorRed           [UIColor redColor]
#define kColorGreen         [UIColor greenColor]
#define kColorBlue          [UIColor blueColor]
#define kColorCyan          [UIColor cyanColor]
#define kColorYellow        [UIColor yellowColor]
#define kColorMagenta       [UIColor magentaColor]
#define kColorOrange        [UIColor orangeColor]
#define kColorPurple        [UIColor purpleColor]
#define kColorBrown         [UIColor brownColor]
#define kColorClear         [UIColor clearColor]

#define kColorTheme         [UIColor colorWithRed:0xF6/255.0 green:0x9F/255.0 blue:0x5A/255.0 alpha:1.0]
#define kColorF0F0F0        [UIColor colorWithRed:0xF0/255.0 green:0xF0/255.0 blue:0xF0/255.0 alpha:1.0]
#define kColor31B4FF        [UIColor colorWithRed:0x31/255.0 green:0xB4/255.0 blue:0xFF/255.0 alpha:1.0]
#define kColorECF1F4        [UIColor colorWithRed:0xEC/255.0 green:0xF1/255.0 blue:0xF4/255.0 alpha:1.0]
#define kColorC3CBCF        [UIColor colorWithRed:0xC3/255.0 green:0xCB/255.0 blue:0xCF/255.0 alpha:1.0]
#define kColorFA4731        [UIColor colorWithRed:0xFA/255.0 green:0x47/255.0 blue:0x31/255.0 alpha:1.0]
#define kColor38C151        [UIColor colorWithRed:0x38/255.0 green:0xC1/255.0 blue:0x51/255.0 alpha:1.0]
#define kColorDE5353        [UIColor colorWithRed:0xDE/255.0 green:0x53/255.0 blue:0x53/255.0 alpha:1.0]
#define kColorE5A3A4        [UIColor colorWithRed:0xE5/255.0 green:0xA3/255.0 blue:0xA4/255.0 alpha:1.0]
#define kColorEDDADA        [UIColor colorWithRed:0xED/255.0 green:0xDA/255.0 blue:0xDA/255.0 alpha:1.0]

#endif /* esportsConst_h */
