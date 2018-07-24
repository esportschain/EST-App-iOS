//
//  HttpTaskClearModelItemsFilter.h
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAObject.h"
#import "HAHttpTask.h"

@interface HttpTaskClearModelItemsFilter : HAObject <HAHttpTaskSucceededFilter>
@property(nonatomic, strong)HAListModel* listModel;

@end
