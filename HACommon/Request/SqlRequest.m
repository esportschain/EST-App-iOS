//
//  SqlRequest.m
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

#import "SqlRequest.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation SqlRequest
SYNTHESIZE_SINGLETON_FOR_CLASS(SqlRequest);

- (id)init
{
    self = [super init];
    if(self) {
        self.fmDB = [FMDatabase databaseWithPath:kPathDataBaseFile];
    }
    
    return self;
}

-(void)dealloc
{
    [self.fmDB close];
    self.fmDB = nil;
}

#pragma mark - public
- (BOOL) executeQuery:(NSString*)sql resultSetBlock:(ResultSetBlock)resultSetBlock
{
    FMResultSet* result = nil;
    [self.fmDB open];
    @try {
        result = [self.fmDB executeQuery:sql];
        if (resultSetBlock) {
            resultSetBlock(result);
        }
    }
    @catch (NSException *exception) {
        if (resultSetBlock) {
            resultSetBlock(nil);
        }
        
        return NO;
    }
    @finally {
        [self.fmDB close];
    }
    
    return YES;
}

- (BOOL) executeUpdate:(NSString*)sql
{
    if (![self.fmDB open]) {
        return NO;
    }
    
    BOOL success = NO;
    success = [self.fmDB executeUpdate:sql];
    
    [self.fmDB close];
    
    return success;
}

- (BOOL) executeUpdates:(NSArray*)sqls
{
    if (!sqls || [sqls count] <= 0) {
        return NO;
    }
    
    if (![self.fmDB open]) {
        return NO;
    }
    
    BOOL success = YES;
    int count = [sqls count];
    for (int i = 0; i < count; i ++) {
        NSString* sql = [sqls objectAtIndex:i];
        if (![self.fmDB executeUpdate:sql]) {
            success = NO;
        }
    }
    
    [self.fmDB close];
    
    return success;
}

- (void) printAll:(NSString*)tableName
{
    [self.fmDB open];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    FMResultSet *set = [self.fmDB executeQuery:sql];
    NSMutableString *string = [[NSMutableString alloc] init];
    while (set.next) {
        [string appendString:@"\n"];
        for (NSUInteger i = 0 ;i < set.columnCount;i++) {
            [string appendFormat:@"%@\n",[set stringForColumnIndex:i]];
        }
    }
    NSLog(@"db %@",string);
    [self.fmDB close];
}

- (void) clearAll:(NSString*)tableName
{
    [self.fmDB open];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    [self.fmDB executeUpdate:sql];
    [self.fmDB close];
}

+ (NSString*)stringWithQuotes:(NSString*)str
{
    NSString *sql = [NSString stringWithFormat:@"'%@'", [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
    return sql;
}

@end
