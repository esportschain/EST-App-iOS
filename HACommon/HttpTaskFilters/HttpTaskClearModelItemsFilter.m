//
//  HttpTaskClearModelItemsFilter.m
//  aimdev
//
//  Created by dongjianbo on 15/11/9.
//  Copyright © 2015年 salam. All rights reserved.
//

#import "HttpTaskClearModelItemsFilter.h"
#import "HADataWrapper.h"

@implementation HttpTaskClearModelItemsFilter

#pragma mark - HAHttpTaskSucceededFilter
- (void)onHAHttpTaskSucceededFilterExecute:(HAHttpTask*)task
{
    HttpResult* result = (HttpResult*)task.result;
    if (result.code == HTTP_RESULT_SUCCESS || result.resultCode == 1) {
        [self.listModel.modelItems removeAllObjects];
    }
}

@end
