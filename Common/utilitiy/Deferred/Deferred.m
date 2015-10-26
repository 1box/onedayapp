//
//  Deferred.m
//  Base
//
//  Created by David Fox on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+NSStringAdditions.h"
#import "NSArray+NSArrayAdditions.h"
#import "DeferredMacros.h"
#import "Deferred.h"


#pragma mark -
#pragma mark SSThreadedDeferred
@interface SSThreadedDeferred : SSDeferred
{
    NSThread *mThread;
    NSThread *mParentThread;
    id<SSDeferredFuncProtocol> mAction;
}

@property(readonly) NSThread *thread;
@property(readonly) NSThread *parentThread;
@property(readonly) id<SSDeferredFuncProtocol> action;

// initializers
+ (SSThreadedDeferred *)threadedDeferred:(id<SSDeferredFuncProtocol>)func;
+ (SSThreadedDeferred *)threadedDeferred:(id<SSDeferredFuncProtocol>)func paused:(BOOL)startPaused;
- (id)initWithFunction:(id<SSDeferredFuncProtocol>)func withObject:(id)arg;
- (id)initWithFunction:(id<SSDeferredFuncProtocol>)func 
            withObject:(id)arg 
             canceller:(id<SSDeferredFuncProtocol>)cancelf
                paused:(BOOL)startPaused;
// internal methods used to run the function
- (void)cbThreadedDeferred:(id)arg;
- (void)cbReturnFromThread:(id)result;

@end

@implementation SSThreadedDeferred

@synthesize thread = mThread;
@synthesize parentThread = mParentThread;
@synthesize action = mAction;

+ (SSThreadedDeferred *)threadedDeferred:(id<SSDeferredFuncProtocol>)func {
    return [[[self alloc] initWithFunction:func withObject:nil] autorelease];
}

+ (SSThreadedDeferred *)threadedDeferred:(id<SSDeferredFuncProtocol>)func paused:(BOOL)paused {
    return [[[self alloc] initWithFunction:func withObject:nil canceller:nil paused:paused] autorelease];
}

- (id)initWithFunction:(id<SSDeferredFuncProtocol>)func
            withObject:(id)arg {
    return [self initWithFunction:func withObject:arg canceller:nil paused:NO];
}

- (id)initWithFunction:(id<SSDeferredFuncProtocol>)func 
            withObject:(id)arg
             canceller:(id<SSDeferredFuncProtocol>)cancelf
                paused:(BOOL)paused {
    if ((self = [super initWithCanceller:cancelf])) {
        mAction = [func retain];
        mParentThread = [[NSThread currentThread] retain];
        mThread = [[NSThread alloc] 
                   initWithTarget:self
                   selector:@selector(cbThreadedDeferred:)
                   object:arg];
        if (!paused) {
            [mThread start];
        } else {
            return [[[SSDeferred deferred] addCallback:callbackTS(self, cbStartThread:)] retain];
        }
    }
    return self;
}

- (id)cbStartThread:(id)arg {
    [mThread start];
    return self;
}

- (void)dealloc {
    [mAction release];
    if (mThread) {
        [mThread cancel];
    }
    [mThread release];
    [mParentThread release];
    [super dealloc];
}

- (void)cbThreadedDeferred:(id)arg {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    id result;
    result = [mAction action:arg];
    if (!result)
        result = [NSNull null];
    [self performSelector:@selector(cbReturnFromThread:) 
                 onThread:mParentThread
               withObject:result
            waitUntilDone:NO];
    [pool drain];
}

- (void)cbReturnFromThread:(id)result 
{
    if ([result isKindOfClass:[NSError class]]) {
        [self errorback:result];
    }
    else if (isDeferred(result)) {
        @throw __CHAINED_DEFERRED_RESULT_ERROR;
    }
    else {
        [self callback:result];
    }
}

@end

#pragma mark -
#pragma mark SSDeferred

@implementation SSDeferred

@synthesize deferredId = mDeferredId;
@synthesize started = mStarted;
@synthesize finalizerFunc = mFinalizerFunc;
@synthesize chained = mChained;

#pragma mark -

+ (SSDeferred *)deferred
{
    return [[[[self class] alloc] initWithCanceller:nil] autorelease];
}

#pragma mark -

+ (id)succeed:(id)result 
{
    SSDeferred * d = [SSDeferred deferred];
    [d callback:result];
    return d;
}

+ (id)fail:(id)result 
{
    SSDeferred * d = [SSDeferred deferred];
    [d errorback:result];
    return d;
}

#pragma mark -
#pragma mark callLater 
+ (id)interReturnValueCallback:(id)value results:(id)results {
    return value;
}

+ (id)wait:(NSTimeInterval)seconds value:(id)value 
{
    SSDeferred *d = [SSDeferred deferred];
    if (!(value == nil)) {
        [d addCallback:curryTS((id)self, @selector(interReturnValueCallback:results:), value)];
    }
    [d performSelector:@selector(callback:)
            withObject:[NSNull null] 
            afterDelay:seconds];
    return d;
}

+ (id)interCallLaterCallback:(id<SSDeferredFuncProtocol>)cb results:(id)results {
    return [cb action:results];
}

+ (id)callLater:(NSTimeInterval)seconds func:(id<SSDeferredFuncProtocol>)func {
    
    return [[SSDeferred wait:seconds value:nil]
            addCallback:
            curryTS((id)self, @selector(interCallLaterCallback:results:), [func retain])];
}

#pragma mark - 

+ (id)maybeDeferred:(id<SSDeferredFuncProtocol>)maybeDeferredf
         withObject:(id)anObject {
    id result;
    id r = [maybeDeferredf action:anObject];
    if (isDeferred(r)) {
        result = r;
    }
    else if ([r isKindOfClass:[NSError class]]) {
        result = [self fail:r];
    }
    else {
        result = [self succeed:r];
    }
    return result;
}

+ (id)deferInThread:(id<SSDeferredFuncProtocol>)func withObject:(id)arg {
    return [[[SSThreadedDeferred alloc] initWithFunction:func withObject:arg] autorelease];
}

#pragma mark -
#pragma mark core func

- (id)continueChain:(id)result 
{
    mPaused -= 1;
    [self resetback:result];
    return nil;
}

- (void)fire {
    id<SSDeferredFuncProtocol> cb = nil;
    int _fired = mFired;
    id result = [[[mResults objectAtIndex:_fired] retain] autorelease];
    while ([mChain count] > 0 && mPaused == 0) {
        //得到callback对,并且从回调链中删除掉
        NSArray *pair = [[[mChain objectAtIndex:0] retain] autorelease];
        [mChain removeObjectAtIndex:0];
        //得到该回调的函数
        id f = [[[pair objectAtIndex:_fired] retain] autorelease];
        if (f == [NSNull null])
            continue;
        //不为空，好了取新的结果
        id newResult = [(id<SSDeferredFuncProtocol>)f action:result];
        result = (newResult == nil) ? [NSNull null] : newResult;
        //重新计算下一个回调函数的位置
        _fired = [result isKindOfClass:[NSError class]] ? 1 : 0;
        
        if ([result isKindOfClass:[self class]]) {
            cb = callbackTS(self, continueChain:);
            mPaused += 1;
        }
    }
    mFired = _fired;
    [mResults replaceObjectAtIndex:mFired withObject:result];
    if ([mChain count] == 0 && mPaused == 0 && !(mFinalizerFunc == nil)) {
        mFinalized = YES;
        [mFinalizerFunc action:result];
    }
    if (! (cb == nil) && mPaused) {
        [result addBoth:cb];
        [result setChained:YES];
    }
}

#pragma mark -
#pragma mark callback

- (void)resetback:(id)result {
    mFired = ([result isKindOfClass:[NSError class]] ? 1 : 0);
    [mResults replaceObjectAtIndex:mFired withObject:
     (result == nil ? [NSNull null] : result)];
    if (mPaused == 0) {
        [self fire];
    }
}

- (void)checkStatus {
    if (mFired != -1) {
        if (!mSilentlyCancelled) {
            @throw [NSException 
                    exceptionWithName:@"AlreadyCalledError"
                    reason:@"Callback or errback can only happen if "
                    @"Deferred has not already fired." 
                    userInfo:nil];
        }
        mSilentlyCancelled = NO;
    }
}

- (void)callback:(id)result {
    [self checkStatus];
    if ([result isKindOfClass:[self class]])
        @throw __CHAINED_DEFERRED_RESULT_ERROR;
    [self resetback:result];
}

- (void)errorback:(id)result {
    [self checkStatus];
    if ([result isKindOfClass:[self class]])
        @throw __CHAINED_DEFERRED_RESULT_ERROR;
    if (![result isKindOfClass:[NSError class]])
        result = [NSError 
                  errorWithDomain:SSDeferredErrorDomain
                  code:SSDeferredGenericError
                  userInfo:nil];
    [self resetback:result];
}

#pragma mark -
#pragma mark add callbacks

- (id)addBoth:(id<SSDeferredFuncProtocol>)fn {
    return [self addCallbacks:fn errorback:fn];
}

- (id)addCallback:(id<SSDeferredFuncProtocol>)fn {
    return [self addCallbacks:fn errorback:nil];
}

- (id)addErrorback:(id<SSDeferredFuncProtocol>)fn {
    return [self addCallbacks:nil errorback:fn];
}

- (id)addCallbacks:(id<SSDeferredFuncProtocol>)cb
         errorback:(id<SSDeferredFuncProtocol>)eb {
    if (mChained) {
        @throw __CHAINED_DEFERRED_REUSE_ERROR;
    }
    if (mFinalized) {
        @throw __FINALIZED_DEFERRED_REUSE_ERROR;
    }
    [mChain addObject:ARRAY(
                            (cb == nil) ? [NSNull null] : (id)cb,
                            (eb == nil) ? [NSNull null] : (id)eb)];
    if (mFired >= 0) {
        [self fire];
    }
    return self;
}

#pragma mark - 
#pragma mark compares

- (NSComparisonResult)compare:(SSDeferred *)otherDeferred {
    return [self.deferredId compare:otherDeferred.deferredId];
}

- (NSComparisonResult)compareDates:(SSDeferred *)otherDeferred {
    return -[self.started compare:otherDeferred.started];
}

- (NSComparisonResult)reverseCompareDates:(SSDeferred *)otherDeferred {
    return [self.started compare:otherDeferred.started];
}

#pragma mark -
#pragma mark control

- (id)pause {
    mPaused += 1;
    return self;
}

- (void)resume {
    if (mPaused >= 0)
        mPaused -= 1;
    if (mPaused)
        return;
    if (mFired >= 0)
        [self fire];
}

- (void)cancel {
    if (mFired == -1) {
        if (mCanceller) {
            [mCanceller action:self];
        } else {
            mSilentlyCancelled = YES;
        }
        if (mFired == -1) {
            [self errorback:
             [NSError
              errorWithDomain:SSDeferredErrorDomain
              code:SSDeferredCanceledError 
              userInfo:nil]];
        }
    } else if ((mFired == 0) && 
               ([[mResults objectAtIndex:mFired] 
                 isKindOfClass:[self class]])) {
        [[mResults objectAtIndex:mFired] cancel];
    }
}

#pragma mark -
#pragma mark alloc and dealloc

- (id)initWithCanceller:(id<SSDeferredFuncProtocol>)cancellerFunc {
    if ((self = [super init])) {
        mChain = [[NSMutableArray arrayWithCapacity:3] retain];
        mDeferredId = [[NSString generateUUID] retain];
        mFired = -1;
        mPaused = 0;
        mStarted = [[NSDate date] retain];
        mResults = [[NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil] retain];
        mSilentlyCancelled = NO;
        mChained = NO;
        mFinalized = NO;
        mCanceller = [cancellerFunc retain];
        mFinalizerFunc = nil;
    }
    return self;
}

- (void)dealloc {
    [mChain release];
    [mResults release];
    [mFinalizerFunc release];
    [mCanceller release];
    [mStarted release];
    [mDeferredId release];
    [super dealloc];
}

@end
