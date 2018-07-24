//
//  GameListCell.m
//  esports
//
//  Created by 焦龙 on 2018/6/15.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "GameListCell.h"
#import "GameListModel.h"

@interface GameListCell()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UIImageView *picIV;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *inprogLbl;
@property (nonatomic, strong) UIView *bindView;
@property (nonatomic, strong) UIView *compltView;
@property (nonatomic, strong) UIView *addedView;

@end

@implementation GameListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.rootLayout = [UIView build:self.contentView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = kDeviceWidth;
            params.height = WRAP_CONTENT;
            
            UIView *baseView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 50;
                
                layout.backgroundColor = kColorWhite;
                
                self.picIV = [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                    
                    params.width = 24;
                    params.height = 24;
                    params.centerVertical = YES;
                    params.leftMargin = 15;
                    
                    [layout setContentMode:UIViewContentModeScaleAspectFill];
                    layout.layer.masksToBounds = YES;
                    layout.layer.cornerRadius = 12.0;
                }];
                
                self.nameLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.centerVertical = YES;
                    params.rightOf = self.picIV;
                    params.leftMargin = 10;
                    params.rightMargin = 140;
                    
                    layout.textColor = kColorBlack;
                    layout.font = kNormalFont(16);
                }];
                
                self.inprogLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.centerVertical = YES;
                    params.alignParentRight = YES;
                    params.rightMargin = 18;
                    
                    layout.text = @"in progress";
                    layout.textColor = kColorLightGray;
                    layout.font = kNormalFont(14);
                }];
                
                self.bindView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.centerVertical = YES;
                    params.alignParentRight = YES;
                    params.rightMargin = 18;
                    
                    UILabel *label = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                        
                        params.width = WRAP_CONTENT;
                        params.height = WRAP_CONTENT;
                        
                        layout.text = @"Bind account";
                        layout.textColor = kColor31B4FF;
                        layout.font = kNormalFont(14);
                    }];
                    
                    [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                        
                        params.width = WRAP_CONTENT;
                        params.height = WRAP_CONTENT;
                        params.centerVertical = YES;
                        params.rightOf = label;
                        params.leftMargin = 9;
                        
                        layout.image = Image(@"icon_right");
                    }];
                }];
                
                self.compltView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                    
                    params.width = WRAP_CONTENT;
                    params.height = WRAP_CONTENT;
                    params.centerVertical = YES;
                    params.alignParentRight = YES;
                    params.rightMargin = 18;
                    
                    UILabel *label = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                        
                        params.width = WRAP_CONTENT;
                        params.height = WRAP_CONTENT;
                        
                        layout.text = @"Recent Matches";
                        layout.textColor = kColorLightGray;
                        layout.font = kNormalFont(14);
                    }];
                    
                    [UIImageView build:layout config:^(RelativeLayoutParams *params, UIImageView *layout) {
                        
                        params.width = WRAP_CONTENT;
                        params.height = WRAP_CONTENT;
                        params.centerVertical = YES;
                        params.rightOf = label;
                        params.leftMargin = 9;
                        
                        layout.image = Image(@"icon_right");
                    }];
                }];
            }];
            
            self.addedView = [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = WRAP_CONTENT;
                params.belowOf = baseView;
                
                layout.backgroundColor = kColorWhite;
            }];
            
            [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 8;
                params.belowOf = self.addedView;
            }];
        }];
    }
    
    return self;
}

- (void)onModelToUI:(HAModel *)model
{
    GameListItemModel *modelItem = (GameListItemModel *)model;
    
    [self.picIV sd_setImageWithURL:[NSURL URLWithString:modelItem.gameIcon] placeholderImage:Image(@"placeholder_avatar")];
    self.nameLbl.text = modelItem.accountName;
    
    for (id tmpView in [self.addedView subviews]) {
        [tmpView removeFromSuperview];
    }
    
    if (modelItem.accountStatus == 1) {
        self.inprogLbl.hidden = YES;
        self.bindView.hidden = YES;
        self.compltView.hidden = NO;
        
        [UIView build:self.addedView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = 64;
            
            [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 0.5;
                params.leftMargin = 15;
                params.rightMargin = 15;
                
                layout.backgroundColor = kColorF0F0F0;
            }];
            
            for (int i = 0; i < 4; i++) {
                GameStatusItemModel *statusItem = (GameStatusItemModel *)[modelItem.modelItems objectAtIndex:i];
                
                [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                    
                    params.width = kDeviceWidth / 4;
                    params.height = MATCH_PARENT;
                    params.leftMargin = (kDeviceWidth / 4) * i;
                    
                    [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                        
                        params.width = WRAP_CONTENT;
                        params.height = WRAP_CONTENT;
                        params.centerHorizontal = YES;
                        params.topMargin = 15;
                        
                        layout.text = statusItem.val;
                        layout.textColor = kColorBlack;
                        layout.font = kBoldFont(20);
                    }];
                    
                    [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                        
                        params.width = WRAP_CONTENT;
                        params.height = WRAP_CONTENT;
                        params.centerHorizontal = YES;
                        params.topMargin = 37;
                        
                        layout.text = statusItem.field;
                        layout.textColor = kColorLightGray;
                        layout.font = kNormalFont(12);
                    }];
                }];
            }
        }];
    } else if (modelItem.accountStatus == 2) {
        self.inprogLbl.hidden = YES;
        self.bindView.hidden = NO;
        self.compltView.hidden = YES;
        
        [UIView build:self.addedView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = MATCH_PARENT;
            params.height = WRAP_CONTENT;
            
            layout.backgroundColor = kRootViewColor;
            
            [UIView build:layout container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = WRAP_CONTENT;
                params.topMargin = 15;
                params.bottomMargin = 15;
                params.leftMargin = 15;
                params.rightMargin = 15;
                
                layout.backgroundColor = kColorEDDADA;
                layout.layer.borderColor = [kColorE5A3A4 CGColor];
                layout.layer.borderWidth = 1.0;
                layout.layer.cornerRadius = 4.0;
                
                [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                    
                    params.width = MATCH_PARENT;
                    params.height = WRAP_CONTENT;
                    params.topMargin = 10;
                    params.leftMargin = 10;
                    params.rightMargin = 10;
                    params.bottomMargin = 10;
                    
                    layout.textColor = kColorDE5353;
                    layout.font = kNormalFont(14);
                    layout.numberOfLines = 0;
                    layout.text = modelItem.accountMsg;
                }];
            }];
        }];
    } else if (modelItem.accountStatus == 3) {
        self.inprogLbl.hidden = NO;
        self.bindView.hidden = YES;
        self.compltView.hidden = YES;
    } else if (modelItem.accountStatus == 4) {
        self.inprogLbl.hidden = YES;
        self.bindView.hidden = NO;
        self.compltView.hidden = YES;
    }
    
    [self.rootLayout requestLayout];
    
    self.height = self.rootLayout.height;
}

@end
