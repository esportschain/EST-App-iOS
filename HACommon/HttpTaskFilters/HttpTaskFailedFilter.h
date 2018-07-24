//
//  HttpTaskFailedFilter.h
//  beacon
//
//  Created by dongjianbo on 16/8/29.
//  Copyright © 2016年 mafengwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAObject.h"
#import "HAHttpTask.h"
#import "SynthesizeSingleton.h"

@interface HttpTaskFailedFilter : NSObject <HAHttpTaskFailedFilter>

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HttpTaskFailedFilter);
@end
