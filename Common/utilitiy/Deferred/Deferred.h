//
//  Deferred.h
//  Base
//
//  Created by David Fox on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeferredFunc.h"
//need more work on it
//本质和nsoperation是一样的，但是operation只有一个回调函数，让很多代码集中在一起了
//主要改进是将每次创建一个线程改变成开始的时候建立一个线程池，然后重用其中的线程。
@interface SSDeferred : NSObject {
    NSString *mDeferredId;
    NSDate *mStarted; 
    
    int mFired;
    int mPaused;
    
    NSMutableArray *mChain;
    NSMutableArray *mResults;
    
    BOOL mSilentlyCancelled;
    BOOL mChained;
    BOOL mFinalized;
    
    id<SSDeferredFuncProtocol>mFinalizerFunc;
    id<SSDeferredFuncProtocol>mCanceller;
}
@property(readonly) NSString *deferredId;
@property(readwrite,retain) NSDate *started;
@property(readwrite,retain)id<SSDeferredFuncProtocol>finalizerFunc;
@property(readwrite)BOOL chained;

+ (SSDeferred *)deferred;
- (id)initWithCanceller:(id<SSDeferredFuncProtocol>)cancellerFunc;
// utility
+ (id)maybeDeferred:(id<SSDeferredFuncProtocol>)maybeDeferredf withObject:(id)anObject;
//+ (id)gatherResults:(NSArray *)list;
+ (id)succeed:(id)result;
+ (id)fail:(id)result;
+ (id)wait:(NSTimeInterval)seconds value:(id)value;
+ (id)callLater:(NSTimeInterval)seconds func:(id<SSDeferredFuncProtocol>)func;
+ (id)deferInThread:(id<SSDeferredFuncProtocol>)func withObject:(id)arg;
//+ (id)defer:(id<SSDeferredFuncProtocol>)func withObject:(id)arg inQueue:(NSOperationQueue *)queue;
// callback methods
- (id)addBoth:(id<SSDeferredFuncProtocol>)fn;
- (id)addCallback:(id<SSDeferredFuncProtocol>)fn;
- (id)addErrorback:(id<SSDeferredFuncProtocol>)fn;
- (id)addCallbacks:(id<SSDeferredFuncProtocol>)cb errorback:(id<SSDeferredFuncProtocol>)eb;
// control methods
- (id)pause;
- (void)resume;
- (void)cancel;
- (void)callback:(id)result;
- (void)errorback:(id)result;
// comparison
- (NSComparisonResult)compare:(SSDeferred *)otherDeferred;
- (NSComparisonResult)compareDates:(SSDeferred *)otherDeferred;
- (NSComparisonResult)reverseCompareDates:(SSDeferred *)otherDeferred;
//private
- (void)resetback:(id)result;

@end
