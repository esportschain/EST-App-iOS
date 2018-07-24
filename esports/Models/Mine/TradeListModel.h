//
//  TradeListModel.h
//  esports
//
//  Created by 焦龙 on 2018/6/21.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "HAModel.h"

@interface TradeListItemModel : HAModel<HADataWrapperParser, HATableViewCellHeight>

@property (nonatomic, strong) NSString *tradeName;
@property (nonatomic, strong) NSString *timeStr;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *amount;

@end

@interface TradeListModel : HAListModel<HAHttpTaskBuildParamsFilter, HAHttpTaskSucceededFilter>

@end
