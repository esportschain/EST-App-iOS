//
//  HATableViewCell.m
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

#import "HATableViewCell.h"

@interface HATableViewCell()
{
#if DEBUG
    UIImageView* _designImageView;
    UIView* _designCoverView;
#endif
}
@end

@implementation HATableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // default selection style
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        // default background color
        self.backgroundColor = [UIColor clearColor];
        
        // 设置cell的宽度
        if ([reuseIdentifier length] > 0 && [reuseIdentifier rangeOfString:@"&width="].location != NSNotFound) {
            NSArray* identifierArray = [reuseIdentifier componentsSeparatedByString:@"&width="];
            if ([identifierArray count] > 0) {
                NSString* widthStr = [identifierArray objectAtIndex:[identifierArray count] - 1];
                if ([widthStr length] > 0) {
                    CGFloat width = [widthStr floatValue];
                    if (width > 0) {
                        self.frame = CGRectMake(0, 0, width, self.height);
                        self.bounds = self.frame;
                        self.contentView.frame = self.frame;
                        self.contentView.bounds = self.frame;
                    }
                }
            }
        }
    }
    
    return self;
}

- (void)onModelToUI:(HAModel*)model
{
    NSAssert(NO, @"在继承类中实现");
}

// 从modelItem计算cell的高度，每个继承类中都要实现一个static的同名函数
+ (NSNumber*)cellHeight:(HAModel*)model cellWidth:(CGFloat)width
{
    if ([model conformsToProtocol:@protocol(HATableViewCellHeight)]) {
        id<HATableViewCellHeight> cellHeightInstance = (id<HATableViewCellHeight>)model;
        if (cellHeightInstance.cellHeight > 0) {
            return [NSNumber numberWithFloat:cellHeightInstance.cellHeight];
        }
    }
    
    return nil;
}

#if DEBUG
- (void) setDesignImage:(UIImage*)image
{
    if (!_designImageView) {
        _designImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [_designImageView setContentMode:UIViewContentModeTopLeft];
        [_designImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_designImageView];
    }
    
    if (!_designCoverView) {
        _designCoverView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [_designCoverView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_designCoverView];
    }
    
    [_designImageView setImage:image];
    [_designCoverView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
}
#endif

#pragma mark - HAViewModel
- (void)notifyModelChanged:(HAModel*)model;
{
    _model = model;
    [self onModelToUI:_model];
    
    if ([model conformsToProtocol:@protocol(HATableViewCellHeight)]) {
        id<HATableViewCellHeight> cellHeightInstance = (id<HATableViewCellHeight>)model;
        cellHeightInstance.cellHeight = self.height;
    }
}

@end
