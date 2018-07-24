//
//  TradeListCell.m
//  esports
//
//  Created by 焦龙 on 2018/6/22.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "TradeListCell.h"
#import "TradeListModel.h"

@interface TradeListCell()

@property (nonatomic, strong) UIView *rootLayout;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UILabel *amountLbl;

@end

@implementation TradeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.rootLayout = [UIView build:self.contentView container:[RelativeLayout layout] config:^(RelativeLayout *container, RelativeLayoutParams *params, UIView *layout) {
            
            params.width = kDeviceWidth;
            params.height = 64;
            
            layout.backgroundColor = kColorWhite;
            
            self.nameLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.leftMargin = 16;
                params.topMargin = 12;
                
                layout.textColor = kColorBlack;
                layout.font = kNormalFont(16);
            }];
            
            self.timeLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.leftMargin = 16;
                params.belowOf = self.nameLbl;
                params.topMargin = 6;
                
                layout.textColor = kColorLightGray;
                layout.font = kNormalFont(12);
            }];
            
            self.amountLbl = [UILabel build:layout config:^(RelativeLayoutParams *params, UILabel *layout) {
                
                params.width = WRAP_CONTENT;
                params.height = WRAP_CONTENT;
                params.centerVertical = YES;
                params.alignParentRight = YES;
                params.rightMargin = 16;
                
                layout.font = kBoldFont(16);
            }];
            
            [UIView build:layout config:^(RelativeLayoutParams *params, UIView *layout) {
                
                params.width = MATCH_PARENT;
                params.height = 1;
                params.alignParentBottom = YES;
                params.leftMargin = 14;
                params.rightMargin = 14;
                
                layout.backgroundColor = kColorF0F0F0;
            }];
        }];
    }
    
    return self;
}

- (void)onModelToUI:(HAModel *)model
{
    TradeListItemModel *modelItem = (TradeListItemModel *)model;
    
    self.nameLbl.text = modelItem.tradeName;
    self.timeLbl.text = modelItem.timeStr;
    
    if (modelItem.type == 1) {
        self.amountLbl.text = [NSString stringWithFormat:@"+%@ EST", modelItem.amount];
        self.amountLbl.textColor = kColorFA4731;
    } else {
        self.amountLbl.text = [NSString stringWithFormat:@"-%@ EST", modelItem.amount];
        self.amountLbl.textColor = kColor38C151;
    }
    
    [self.rootLayout requestLayout];
    
    self.height = self.rootLayout.height;
}

@end
