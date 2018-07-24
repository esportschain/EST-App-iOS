//
//  uiConst.h
//  aimdev
//
//  Created by dongjianbo on 14-6-7.
//  Copyright (c) 2014年 salam. All rights reserved.
//

#ifndef __uiConst_h_
#define __uiConst_h_

// 背景色
#define kRootViewColor  [UIColor colorWithRed:0xF0/255.0 green:0xF0/255.0 blue:0xF0/255.0 alpha:1.0]

#define kNormalFont(fontSize)      [UIFont systemFontOfSize:fontSize]
#define kBoldFont(fontSize)        [UIFont boldSystemFontOfSize:fontSize]
#define kItalicFont(fontSize)      [UIFont italicSystemFontOfSize:fontSize]

// 配色
#define kColor06a3F9    [UIColor colorWithRed:0x06/255.0 green:0xa3/255.0 blue:0xf9/255.0 alpha:1.0]
#define kColor222222    [UIColor colorWithRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:1.0]
#define kColor333333    [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0]
#define kColor444444    [UIColor colorWithRed:0x44/255.0 green:0x44/255.0 blue:0x44/255.0 alpha:1.0]
#define kColor555555    [UIColor colorWithRed:0x55/255.0 green:0x55/255.0 blue:0x55/255.0 alpha:1.0]
#define kColor666666    [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0]
#define kColor777777    [UIColor colorWithRed:0x77/255.0 green:0x77/255.0 blue:0x77/255.0 alpha:1.0]
#define kColor999999    [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0]
#define kColorD7D7D7    [UIColor colorWithRed:0xd7/255.0 green:0xd7/255.0 blue:0xd7/255.0 alpha:1.0]
#define kColorF3F3F3    [UIColor colorWithRed:0xF3/255.0 green:0xF3/255.0 blue:0xF3/255.0 alpha:1.0]
#define kColorFCFCFC    [UIColor colorWithRed:0xFC/255.0 green:0xFC/255.0 blue:0xFC/255.0 alpha:1.0]
#define kColor000000    [UIColor colorWithRed:0x00/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1.0]
#define kColor2fa414    [UIColor colorWithRed:0x2f/255.0 green:0xa4/255.0 blue:0x14/255.0 alpha:1.0]
#define kColorSmsNum    [UIColor colorWithRed:241/255.0 green:0/255.0 blue:33/255.0 alpha:1.0]
#define kColorNavButton [UIColor colorWithRed:35/255.0 green:166/255.0 blue:245/255.0 alpha:1.0]

// 按钮
#define kImportantButton(button) \
[button.layer setCornerRadius:2.0f];\
button.layer.masksToBounds = YES;\
[button setBackgroundImage:[[HAImageUtil imageWithColor:[UIColor colorWithRed:0x06/255.0 green:0xa3/255.0 blue:0xf9/255.0 alpha:1.0f] size:4] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal];\
[button setBackgroundImage:[[HAImageUtil imageWithColor:[UIColor colorWithRed:0x00/255.0 green:0x7b/255.0 blue:0xbe/255.0 alpha:1.0f] size:4] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateHighlighted];\
[button setBackgroundImage:[[HAImageUtil imageWithColor:[UIColor colorWithRed:0xe5/255.0 green:0xe5/255.0 blue:0xe5/255.0 alpha:1.0f] size:4] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateDisabled];\
[button setTitleColor:[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:1.0f] forState:UIControlStateNormal];\
[button setTitleColor:[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.7f] forState:UIControlStateHighlighted];\
[button setTitleColor:[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0f] forState:UIControlStateDisabled];\
[button.titleLabel setFont:kNormalFont(16)];

#define kNormalButton(button) \
[button setBackgroundImage:[UIImage imageNamed:@"btn_normal"] forState:UIControlStateNormal];\
[button setBackgroundImage:[UIImage imageNamed:@"btn_highlighted"] forState:UIControlStateHighlighted];\
[button setBackgroundImage:[UIImage imageNamed:@"btn_normal"] forState:UIControlStateDisabled];\
[button setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0f] forState:UIControlStateNormal];\
[button setTitleColor:[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:1.0f] forState:UIControlStateHighlighted];\
[button setTitleColor:[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0f] forState:UIControlStateDisabled];\
[button.titleLabel setFont:kNormalFont(16)];

#endif // __uiConst_h_


