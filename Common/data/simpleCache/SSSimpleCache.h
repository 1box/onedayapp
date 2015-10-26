//
//  SSSimpleCache.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSSimpleCache : NSObject

+ (SSSimpleCache *)sharedCache;

//不能保证cache一定存在， 其检查cached的plist， 不检查磁盘文件。
- (BOOL)quickCheckIsCacheExist:(NSString *)url;
- (BOOL)quickCheckIsArrayCacheExist:(NSArray *)URLAndHeaders;

- (BOOL)isCacheExist:(NSString *)url;
- (void)clearCache;
- (void)startGarbageCollection;
- (void)stopGarbageCollection;
//asynchronous method
- (void)setData:(NSData*)data forKey:(NSString*)key;
- (void)removeCacheForUrl:(NSString *)url;
- (NSData *)dataForUrl:(NSString *)url;
- (NSData *)dataForURLAndHeaders:(NSArray *)URLAndHeaders;

// in MB
+ (float)cacheSize;
+ (BOOL)hasCacheSize;

@end
