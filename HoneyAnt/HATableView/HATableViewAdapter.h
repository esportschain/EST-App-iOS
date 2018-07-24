//
//  HATableViewAdapter.h
//  aimdev
//
//  Created by dongjianbo on 15-1-4.
//  Copyright 2015 www.aimdev.cn
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "HAObject.h"

#define CELL_HEIGHT_SEL     @"cellHeight:cellWidth:"
#define kCellIdentifier(cellname, width) [NSString stringWithFormat:@"%@&width=%0.2f", cellname, width]

/**
 * HATableViewDelegate
 */
@protocol HATableViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath model:(HAModel*)model;
@end

/**
 * HATableViewAdapter
 */
@interface HATableViewAdapter : HAObject<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) HAListModel* listModel;
@property(nonatomic, strong) Class<HATableViewCell> cellClass;

@property(nonatomic, weak) id<HATableViewDelegate> tableViewDelegate;
@property(nonatomic, weak) id<HATableViewCellDelegate> cellDelegate;

@property(nonatomic, strong) HATableViewCell* calHeightCell;
@end
