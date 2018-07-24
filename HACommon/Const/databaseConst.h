//
//  databaseConst.h
//  aimdev
//
//  Created by dongjianbo on 14-6-7.
//  Copyright (c) 2014年 salam. All rights reserved.
//

#ifndef __databaseConst_h_
#define __databaseConst_h_

// 下载帖子
#define kCreateDownloadTable @"CREATE TABLE if not exists DownloadPostsTable(\
ID INTEGER PRIMARY KEY AUTOINCREMENT,\
Tid text,\
Title text,\
FileName text)"
#define kInsertDownloadTable(Tid,Title,FileName) [NSString stringWithFormat:@"INSERT INTO DownloadPostsTable(Tid,Title,FileName) SELECT \"%@\",\"%@\",\"%@\" WHERE NOT EXISTS(SELECT Tid FROM DownloadPostsTable WHERE Tid=\"%@\")",Tid,Title,FileName,Tid]
#define kQueryDownloadTable(Tid) [NSString stringWithFormat:@"SELECT * FROM DownloadPostsTable WHERE Tid=%@", Tid]
#define kDeleteDownloadTable(Tid) [NSString stringWithFormat:@"DELETE FROM DownloadPostsTable WHERE Tid=%@", Tid]

// 已读帖子
#define kCreateReadTable @"CREATE TABLE if not exists ReadTable(\
id INTEGER PRIMARY KEY AUTOINCREMENT,\
tid text,\
Reserve1 text,\
Reserve2 text,\
Reserve3 text,\
Reserve4 text,\
Reserve5 text,\
Reserve6 text)"
#define kInsertReadTable(tid) [NSString stringWithFormat:@"INSERT INTO ReadTable(tid) SELECT \"%@\" WHERE NOT EXISTS(SELECT tid FROM ReadTable WHERE tid=\"%@\")",tid, tid]
#define kQueryReadTable(tid) [NSString stringWithFormat:@"SELECT * FROM ReadTable WHERE tid=%@", tid]
#define kQueryDownloadTable(Tid) [NSString stringWithFormat:@"SELECT * FROM DownloadPostsTable WHERE Tid=%@", Tid]
#endif // __databaseConst_h_


