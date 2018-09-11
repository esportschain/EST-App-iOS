//
//  GameListModel.h
//  esports
//
//  Created by 焦龙 on 2018/6/14.
//  Copyright © 2018年 esportschain. All rights reserved.
//

#import "HAModel.h"

@interface GameStatusItemModel : HAModel<HADataWrapperParser>

@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSString *val;

@end

@interface GameListItemModel : HAListModel<HADataWrapperParser, HATableViewCellHeight>

@property (nonatomic, strong) NSString *gameIcon;
@property (nonatomic, strong) NSString *gameType;
@property (nonatomic, assign) int accountStatus;
@property (nonatomic, strong) NSString *accountMsg;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSMutableDictionary *uriDic;

@end

@interface GameListModel : HAListModel<HAHttpTaskBuildParamsFilter, HAHttpTaskSucceededFilter>

@end
