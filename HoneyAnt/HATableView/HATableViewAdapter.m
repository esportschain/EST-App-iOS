//
//  HATableViewAdapter.m
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

#import "HATableViewAdapter.h"

@interface HATableViewAdapter()
@end

@implementation HATableViewAdapter

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listModel.modelItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAModel *model = [self.listModel.modelItems objectAtIndex:indexPath.row];
    
    NSString* identifier = kCellIdentifier(NSStringFromClass(self.cellClass), tableView.width);
    HATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        Class cellClass = self.cellClass;
        if (cellClass) {
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        // 设置cell代理
        cell.delegate = self.cellDelegate;
    }
    
    [cell notifyModelChanged:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAModel *model = [self.listModel.modelItems objectAtIndex:indexPath.row];
    
    Class cellClass = self.cellClass;
    NSNumber *height = ((NSNumber*(*)(Class, SEL, HAModel*, float))objc_msgSend)([cellClass class], NSSelectorFromString(CELL_HEIGHT_SEL), model, tableView.frame.size.width);
    if (height) {
        return [height floatValue];
    }
    else {
        if (!self.calHeightCell) {
            if (cellClass) {
                self.calHeightCell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self.cellClass)];
            }
        }
        
        [self.calHeightCell notifyModelChanged:model];
        
        return self.calHeightCell.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAModel *model = [self.listModel.modelItems objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:model:)]) {
        [self.tableViewDelegate tableView:(UITableView*)tableView didSelectRowAtIndexPath:indexPath model:model];
    }
}

@end
