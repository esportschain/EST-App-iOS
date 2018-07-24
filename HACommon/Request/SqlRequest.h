//
//  SqlRequest.h
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

#import "FMDatabase.h"
#import "FMResultSet.h"
#import "SynthesizeSingleton.h"
#import "HAObject.h"

//[[SqlRequest sharedInstance] executeUpdate:@"CREATE TABLE xxx"];
//__weak typeof(self) weakSelf = self;
//NSString* sql = [NSString stringWithFormat:@"SELECT * FROM DownloadPostsTable ORDER BY ID DESC"];
//[[SqlRequest sharedInstance] executeQuery:sql resultSetBlock:^(FMResultSet *resultSet) {
//    while (resultSet.next) {
//        DownloadListItem* item = [[DownloadListItem alloc] init];
//        [item parseSqlData:resultSet];
//        [weakSelf.modelItems addObject:item];
//    }
//}];

typedef void (^ResultSetBlock)(FMResultSet* resultSet);

@interface SqlRequest : HAObject

@property (nonatomic, retain) FMDatabase* fmDB;

- (BOOL) executeQuery:(NSString*)sql resultSetBlock:(ResultSetBlock)resultSetBlock;
- (BOOL) executeUpdate:(NSString*)sql;
- (BOOL) executeUpdates:(NSArray*)sqls;

- (void) printAll:(NSString*)tableName;
- (void) clearAll:(NSString*)tableName;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SqlRequest);
@end
