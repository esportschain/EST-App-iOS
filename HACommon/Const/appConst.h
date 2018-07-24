//
//  Const.h
//  aimdev
//
//  Created by dongjianbo on 14-6-7.
//  Copyright (c) 2014年 salam. All rights reserved.
//

#ifndef __Const_h_
#define __Const_h_

#define CONSUMER_KEY        @"m5AMGLnVvMXunKUAKsU8IabvPv65id3X"
#define CONSUMER_SECRET     @"xi56AzMBM5kZmShaqnyw3x5Cza3AyvkL"

// 主目录
#define kPathRoot           [NSString stringWithFormat:@"%@/Library/nzny", NSHomeDirectory()]
// 文件缓存目录
#define kPathCache          [NSString stringWithFormat:@"%@/cache", kPathRoot]
// Http请求缓存目录
#define kPathUrlCache          [NSString stringWithFormat:@"%@/urlcache", kPathRoot]
// 下载暂存目录
#define kPathDownload       [NSString stringWithFormat:@"%@/down", kPathRoot]
// sqlite数据库文件地址
#define kPathDataBaseFile   [NSString stringWithFormat:@"%@/maindb.sqlite", kPathRoot]
// 帖子文件夹存储路径
#define kPathPostsFolder(tid)        [NSString stringWithFormat:@"%@/%@", kPathPosts, tid]
// 下载文件压缩包
#define kPathDownloadZipFile(tid)   [NSString stringWithFormat:@"%@/%@.zip", kPathPostsFolder(tid), tid]

#endif // __Const_h_


