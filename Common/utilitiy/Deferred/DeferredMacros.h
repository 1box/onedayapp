//
//  DeferredMacros.h
//  Base
//
//  Created by David Fox on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifdef __OBJC__

#import "DeferredFunc.h"

static inline id<SSDeferredFuncProtocol> interCurryTS(id target, SEL selector, ...)
{
    NSMethodSignature *sig = ([target isKindOfClass:[NSObject class]] ? 
                              [target methodSignatureForSelector:selector] :
                              [[target class] instanceMethodSignatureForSelector:selector]);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    va_list argumentList;
    va_start(argumentList, selector);
    id arg;
    int i = 0;
    while ((arg = va_arg(argumentList, id))) {
        [invocation setArgument:&arg atIndex:i + 2];
        i++;
    }
    if (! (i == ([sig numberOfArguments] - 3))) {
        @throw [NSException exceptionWithName:@"CurryArgumentCountException" 
                                       reason:@"The number of arguments supplied to curry must be one "
                @"less than the total number of arguments for the given implementation"
                                     userInfo:nil];
    }
    va_end(argumentList);
    [invocation retainArguments];
    return [SSDeferredFunc fromInvocation:invocation parameterIndex:i];
}

#define curryTS(__target, __selector, args...) interCurryTS(__target, __selector, args, nil)
#define isDeferred(__obj) [__obj isKindOfClass:[SSDeferred class]]

#define callbackS(sel) [SSDeferredFunc fromSelector:@selector(sel)]
#define callbackTS(tgt, sel) [SSDeferredFunc fromSelector:@selector(sel) target:tgt]
#define callbackP(fp) [SSDeferredFunc fromPointer:fp]
#define callbackI(inv, i) [SSDeferredFunc fromInvocation:inv parameterIndex:i]

#define __CHAINED_DEFERRED_RESULT_ERROR [NSException \
    exceptionWithName:@"DeferredInstanceError" \
    reason:@"Deferred instances can only be chained " \
           @"if they are the result of a callback" \
    userInfo:nil]
#define __CHAINED_DEFERRED_REUSE_ERROR [NSException \
    exceptionWithName:@"DeferredInstanceError" \
    reason:@"Chained deferreds can not be re-used" \
    userInfo:nil]
#define __FINALIZED_DEFERRED_REUSE_ERROR [NSException \
    exceptionWithName:@"DeferredInstanceError" \
    reason:@"Finalized deferreds can not be re-used" \
    userInfo:nil]
#define SSDeferredErrorDomain @"SSDeferred"
#define SSDeferredCanceledError 419
#define SSDeferredGenericError 420

#endif