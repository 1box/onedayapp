//
//  SSSimpleCache.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/*
 SimpleCache2 文件夹从囧图1.7 开始使用，20120619
 之前的SimpleCache.将删除在垃圾回收时候删除。
 
 */

#import "SSSimpleCache.h"
//#import "BaseHeader.h"

#define HashLength 2
#define CacheDictionaryName @"SimpleCache.plist"
#define kCacheSizeKey   @"kCacheSizeKey"


@interface SSSimpleCache()
{
    BOOL _stopGarbageCollection;
}

@property (retain) NSMutableDictionary * cacheDictionary;
@property (retain) NSOperationQueue * operationQueue;
@property (assign) NSTimeInterval defaultTimeoutInterval;
//- (void)reCalculateCacheSize;
- (void)removeItemFromCache:(NSString*)key updateSize:(BOOL)update;
@end

static SSSimpleCache * _sharedCache = nil;
static NSString * _cacheDirectory = nil;

static inline NSString* CacheDirectory() {
	if(!_cacheDirectory) {
		_cacheDirectory = [[@"SimpleCache2" stringCachePath] copy];
	}
	
	return _cacheDirectory;
}

static inline NSString* cachePathForKey(NSString* key) {
	return [CacheDirectory() stringByAppendingPathComponent:key];
}

static inline NSString * cachePathForKeyWithHashFolder(NSString * key) {
    NSString * path = @"";
    if(HashLength > 0) {
        path = [key length] >= HashLength ? [key substringToIndex:HashLength] : @"";
    }
    path = [path stringByAppendingPathComponent:key];
    return [CacheDirectory() stringByAppendingPathComponent:path];
}


@implementation SSSimpleCache

@synthesize cacheDictionary = _cacheDictionary;
@synthesize operationQueue = _operationQueue;
@synthesize defaultTimeoutInterval = _defaultTimeoutInterval;

+ (SSSimpleCache *)sharedCache
{
    @synchronized(self) {
        if (!_sharedCache) {
            _sharedCache = [[SSSimpleCache alloc] init];
        }
    }
    return _sharedCache;
}

- (void)dealloc
{
    self.cacheDictionary = nil;
    self.operationQueue = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _stopGarbageCollection = NO;
        
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:cachePathForKey(CacheDictionaryName)];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            _cacheDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
        }
        else {
            _cacheDictionary = [[NSMutableDictionary alloc] init];
        }
        
        _operationQueue = [[NSOperationQueue alloc] init];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:CacheDirectory() withIntermediateDirectories:YES attributes:nil error:NULL];
        
        self.defaultTimeoutInterval = SS_WEEK;
        
    }
    return self;
}

#pragma mark -- save
- (void)saveCacheDictionary
{
    @synchronized(self) {
        [_cacheDictionary writeToFile:cachePathForKey(CacheDictionaryName) atomically:YES];
    }
}

- (void)writeData:(NSData *)data toPath:(NSString *)path
{
    if (HashLength > 0) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
	[data writeToFile:path atomically:YES];
    
    NSError *error = nil;
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if(!error)
    {
        float size = [SSSimpleCache cacheSize];
        size += [[dict objectForKey:NSFileSize] unsignedLongLongValue] / (1024.f * 1024);
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:size] forKey:kCacheSizeKey];
    }
}


- (void)saveAfterDelay { // Prevents multiple-rapid saves from happening, which will slow down your app
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveCacheDictionary) object:nil];
	[self performSelector:@selector(saveCacheDictionary) withObject:nil afterDelay:0.3];
}

//asynchronous method
- (void)setData:(NSData*)data forKey:(NSString*)key
{
	[self setData:data forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    if (data == nil) return;
    
    NSString * real_key = [key MD5HashString];
    NSString * cachePath = cachePathForKeyWithHashFolder(real_key);
    NSInvocation * writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
    [writeInvocation setTarget:self];
    [writeInvocation setSelector:@selector(writeData:toPath:)];
    [writeInvocation setArgument:&data atIndex:2];
    [writeInvocation setArgument:&cachePath atIndex:3];
    
    [self performDiskWriteOperation:writeInvocation];
    
    [_cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] forKey:real_key];
    
    [self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES]; // Need to make sure the save delay get scheduled in the main runloop, not the current threads
    
}

#pragma mark -- delete

- (void)deletePreviousVersionCache
{
    // for "SimpleCache"
    NSString * oldFolder = [@"SimpleCache" stringCachePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldFolder] && !_stopGarbageCollection) {
        NSDirectoryEnumerator * dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:oldFolder];
        NSString *file;
        while (file = [dirEnum nextObject]) {
            if (_stopGarbageCollection) {
                break;
            }
            [[NSFileManager defaultManager] removeItemAtPath:[oldFolder stringByAppendingPathComponent:file] error:NULL];
        }
    }
}

- (void)deleteDataByKeyArrayAndSavePathDictionary:(NSArray *)keyArray
{
    for (NSString * key in keyArray) {
        if (_stopGarbageCollection) {
            break;
        }
        [[NSFileManager defaultManager] removeItemAtPath:cachePathForKeyWithHashFolder(key) error:NULL];
        [_cacheDictionary removeObjectForKey:key];
    }
    [self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES]; // Need to make sure the save delay get scheduled in the main runloop, not the current threads
    
    [self deletePreviousVersionCache];
}

- (void)deleteDataAtPath:(NSString *)path
{
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)startGarbageCollection
{
    _stopGarbageCollection = NO;
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        UIApplication *app = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier taskId;
        taskId = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:taskId];
        }];
        
        if (taskId == UIBackgroundTaskInvalid) {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary * cacheDict = [_cacheDictionary copy];
            for (NSString * key in [cacheDict allKeys]) {
                if (_stopGarbageCollection) {
                    break;
                }
                NSDate * date = [cacheDict objectForKey:key];
                if ([[[NSDate date] earlierDate:date] isEqualToDate:date]) {
                    [[NSFileManager defaultManager] removeItemAtPath:cachePathForKeyWithHashFolder(key) error:NULL];
                    [_cacheDictionary removeObjectForKey:key];
                }
            }
            [cacheDict release];
            [self performSelectorOnMainThread:@selector(saveCacheDictionary) withObject:nil waitUntilDone:YES];
            
            NSString * forderPath = CacheDirectory();
            NSArray * forderAry = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:forderPath error:nil];
            for (NSString * forderNameStr in forderAry) {
                NSString * sonForderPath = [forderPath stringByAppendingPathComponent:forderNameStr];
                BOOL isDirectory = NO;
                [[NSFileManager defaultManager] fileExistsAtPath:sonForderPath isDirectory:&isDirectory];
                if (isDirectory && [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sonForderPath error:nil] count] == 0) {
                    [[NSFileManager defaultManager] removeItemAtPath:sonForderPath error:nil];
                }
            }
            
            [self deletePreviousVersionCache];
            
            [app endBackgroundTask:taskId];
        });
        
    }
    else {
        
        NSDictionary * cacheDict = [_cacheDictionary copy];
        NSArray * ary = [cacheDict allKeys];
        NSInvocation * deleteInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(deleteDataByKeyArrayAndSavePathDictionary:)]];
        [deleteInvocation setTarget:self];
        [deleteInvocation setSelector:@selector(deleteDataByKeyArrayAndSavePathDictionary:)];
        [deleteInvocation setArgument:&ary atIndex:2];
        [self performDiskWriteOperation:deleteInvocation];
        [cacheDict release];
    }
}

- (void)clearCache
{
    NSDictionary * cacheDict = [_cacheDictionary copy];
    
    for(NSString* key in [cacheDict allKeys]) {
		[self removeItemFromCache:key updateSize:NO];
	}
    [cacheDict release];
    [self saveCacheDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:.0f] forKey:kCacheSizeKey];
}

- (void)removeCacheForUrl:(NSString *)url
{
    NSString * real_key = [url MD5HashString];
	[self removeItemFromCache:real_key updateSize:YES];
	[self saveCacheDictionary];
}


#pragma mark -- operation
- (void)performDiskWriteOperation:(NSInvocation *)invoction
{
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invoction];
	[_operationQueue addOperation:operation];
	[operation release];
}

- (void)removeItemFromCache:(NSString*)key updateSize:(BOOL)update
{
    NSString* cachePath = cachePathForKeyWithHashFolder(key);
	
	NSInvocation* deleteInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(deleteDataAtPath:)]];
	[deleteInvocation setTarget:self];
	[deleteInvocation setSelector:@selector(deleteDataAtPath:)];
	[deleteInvocation setArgument:&cachePath atIndex:2];
	
	[self performDiskWriteOperation:deleteInvocation];
	[_cacheDictionary removeObjectForKey:key];
    if(update)
    {
        NSError *error = nil;
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:&error];
        if(!error)
        {
            float fileSize = [[dict objectForKey:NSFileSize] unsignedLongLongValue] / (1024.f * 1024);
            float cacheSize = [SSSimpleCache cacheSize];
            cacheSize = cacheSize > fileSize ? cacheSize - fileSize : 0;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:cacheSize] forKey:kCacheSizeKey];
        }
    }
}

#pragma mark -- judge

- (BOOL)quickCheckIsCacheExist:(NSString *)url
{
    NSString * real_key = [url MD5HashString];
    if ([_cacheDictionary objectForKey:real_key] != nil) {
        return YES;
    }
    return NO;
}

- (BOOL)quickCheckIsArrayCacheExist:(NSArray *)URLAndHeaders
{
    if ([URLAndHeaders count] == 0) {
        return NO;
    }
    for (int i = 0; i < [URLAndHeaders count]; i++) {
        if([self quickCheckIsCacheExist:[[URLAndHeaders objectAtIndex:i] objectForKey:@"url"]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCacheExist:(NSString *)url
{
    NSString * real_key = [url MD5HashString];
    //    if ([_cacheDictionary objectForKey:real_key] != nil) {
    //        return YES;
    //    }
    
    NSString * cacheFile = cachePathForKeyWithHashFolder(real_key);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        return YES;
    }
    return NO;
}

#pragma mark -- get

- (NSData *)dataForURLAndHeaders:(NSArray *)URLAndHeaders
{
    if ([URLAndHeaders count] == 0) {
        return nil;
    }
    for (int i = 0; i < [URLAndHeaders count]; i++) {
        NSData * data = [self dataForUrl:[[URLAndHeaders objectAtIndex:i] objectForKey:@"url"]];
        if (data != nil) {
            return data;
        }
    }
    return nil;
}

- (NSData *)dataForUrl:(NSString *)url
{
    NSString * real_key = [url MD5HashString];
	if (![self isCacheExist:real_key]) {
		return [NSData dataWithContentsOfFile:cachePathForKeyWithHashFolder(real_key) options:0 error:NULL];
	}
    else {
		return nil;
	}
}

#pragma mark -- control

- (void)stopGarbageCollection
{
    _stopGarbageCollection = YES;
}

#pragma mark - cache size
+ (void)reCalculateCacheSize
{
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:cachePathForKey(@"SimpleCache.plist")];
    float fileSize = [[dict allKeys] count] * 50 * 1024;
    NSNumber *size = [NSNumber numberWithFloat:fileSize / (float)(1024 * 1024)];
    [[NSUserDefaults standardUserDefaults] setObject:size forKey:kCacheSizeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)hasCacheSize
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSizeKey] != nil;
}

+ (float)cacheSize
{
    if(![SSSimpleCache hasCacheSize])
    {
        [SSSimpleCache reCalculateCacheSize];
    }
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kCacheSizeKey] floatValue];
}

@end
