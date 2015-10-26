//
//  DeferredFunc.m
//  Base
//
//  Created by David Fox on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "CorePreprocessorMacros.h"
#import "DeferredFunc.h"

#pragma mark -
#pragma mark SSDeferredFuncFromSelector
/**
 * arg代表了调用对象不是参数，切记切记
 */
@interface SSDeferredFuncFromSelector : SSDeferredFunc {
    SEL mSelector;
}

@property(readonly) SEL selector;
- (SSDeferredFuncFromSelector *)initWithSelector:(SEL)action;

@end

@implementation SSDeferredFuncFromSelector

@synthesize selector = mSelector;

- (SSDeferredFuncFromSelector *)initWithSelector:(SEL)action{
    if ((self = [super init])) {
        mSelector = action;
    }
    return self;
}

- (id)action:(id)arg {
    return [arg performSelector:mSelector];
}

@end

#pragma mark - 
#pragma mark SSDeferredFuncFromSelectorWithTarget

@interface SSDeferredFuncFromSelectorWithTarget : SSDeferredFunc {
    SEL mSelector;
    NSObject *mTarget;
}

@property(readonly) SEL selector;
@property(readonly) NSObject *target;
- (SSDeferredFuncFromSelectorWithTarget *)initWithSelector:(SEL)action target:(NSObject *)target;

@end

@implementation SSDeferredFuncFromSelectorWithTarget

@synthesize selector = mSelector;
@synthesize target = mTarget;

- (SSDeferredFuncFromSelectorWithTarget *)initWithSelector:(SEL)action target:(NSObject *)target {
    if (![target respondsToSelector:action]) {
        @throw [NSException 
                exceptionWithName:NSInvalidArgumentException 
                reason:[NSString stringWithFormat:@"%@ does not respond to selector %s", target, sel_getName(action)]
                userInfo:nil];
    }
    if ((self = [super init])) {
        mSelector = action;
        mTarget = [target retain];
    }
    return self;
}

- (id)action:(id)arg {
    return [mTarget performSelector:mSelector withObject:arg];
}

- (void)dealloc {
    [mTarget release];
    [super dealloc];
}
@end

#pragma mark -
#pragma mark SSDeferredFuncFromPointer

@interface SSDeferredFuncFromPointer : SSDeferredFunc {
    SSDeferredFuncPtr mFunction;
}
- (SSDeferredFuncFromPointer *)initWithPointer:(SSDeferredFuncPtr)funcPtr;
@end

@implementation SSDeferredFuncFromPointer
-(SSDeferredFuncFromPointer *)initWithPointer:(SSDeferredFuncPtr)funcPtr {
    if ((self = [super init])) {
        mFunction = funcPtr;
    }
    return self;
}
- (id)action:(id)arg {
    return (*mFunction)(arg);
}
@end

#pragma mark -
#pragma mark SSDeferredFuncFromInvocation

@interface SSDeferredFuncFromInvocation : SSDeferredFunc {
    NSInvocation *mInvocation;
    NSUInteger mIndex;
}
- (SSDeferredFuncFromInvocation *)initWithInvocation:(NSInvocation *)inv parameterIndex:(NSUInteger)idx;
@end

@implementation SSDeferredFuncFromInvocation
- (SSDeferredFuncFromInvocation *)initWithInvocation:(NSInvocation *)inv parameterIndex:(NSUInteger)idx {
    if ((self = [super init])) {
        mInvocation = [inv retain];
        mIndex = idx;
    }
    return self;
}
- (id)action:(id)arg {
    [mInvocation setArgument:&arg atIndex:(mIndex + 2)];
    [mInvocation invoke];
    id anObject;
    [mInvocation getReturnValue:&anObject];
    return anObject;
}
- (void)dealloc {
    [mInvocation release];
    [super dealloc];
}

@end

#pragma mark -
#pragma mark SSDeferredFuncComposition simple lamda

@interface SSDeferredFuncComposition : SSDeferredFunc {
    SSDeferredFunc *mF;
    SSDeferredFunc *mG;
}

- (SSDeferredFuncComposition *)initWithF:(SSDeferredFunc *)aF andG:(SSDeferredFunc *)aG;
@end

@implementation SSDeferredFuncComposition

- (SSDeferredFuncComposition *)initWithF:(SSDeferredFunc *)aF andG:(SSDeferredFunc *)aG {
    if ((self = [super init])) {
        mF = [aF retain];
        mG = [aG retain];
    }
    return self;
}

- (void)dealloc {
    [mF release];
    [mG release];
    [super dealloc];
}

- (id)action:(id)arg {
    return [mF action:[mG action:arg]];
}

@end

#pragma mark -
#pragma mark SSDeferredFunc
@implementation SSDeferredFunc

+ (SSDeferredFunc *)fromSelector:(SEL)action
{
    return [[[SSDeferredFuncFromSelector alloc] initWithSelector:action] autorelease];
}

+ (SSDeferredFunc *)fromSelector:(SEL)action target:(NSObject *)target
{
    return [[[SSDeferredFuncFromSelectorWithTarget alloc] initWithSelector:action target:target] autorelease];
}

+ (SSDeferredFunc *)fromPointer:(SSDeferredFuncPtr)funcPtr
{
    return [[[SSDeferredFuncFromPointer alloc] initWithPointer:funcPtr] autorelease];
}
/**
 * parameterIndex 最少为2 一个是self，一个是_cmd 
 */
+ (SSDeferredFunc *)fromInvocation:(NSInvocation *)inv parameterIndex:(NSUInteger)i
{
    return [[[SSDeferredFuncFromInvocation alloc] initWithInvocation:inv parameterIndex:i] autorelease];
}
/**
 * 用自己的调用结果，调用下一个func
 */
- (SSDeferredFunc *)andThen:(SSDeferredFunc  *)other
{
    return [other composeWith:self];
}
/*
 *用调用另一个func的结果，调用自己
 */
- (SSDeferredFunc *)composeWith:(SSDeferredFunc *)other
{
    return [[[SSDeferredFuncComposition alloc] initWithF:self andG:other] autorelease];
}

- (id)action:(id)arg {
    @throw [NSException exceptionWithName:@"InvalidOperation" reason:@"Must override -(id)action:(id) in subclass of SSDeferredFunc" userInfo:nil];
}
@end
