//
//  DeferredFunc.h
//  Base
//
//  Created by David Fox on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (*SSDeferredFuncPtr)(id);

@protocol SSDeferredFuncProtocol <NSObject>

- (id)action:(id)arg;

@end

/**
 *工厂，子类不做任何异常处理，最好明白自己为什么要写这个函数，在函数内做好异常处理
*/
@interface SSDeferredFunc : NSObject<SSDeferredFuncProtocol> {
    
}

+ (SSDeferredFunc *)fromSelector:(SEL)action;
+ (SSDeferredFunc *)fromSelector:(SEL)action target:(NSObject *)target;
+ (SSDeferredFunc *)fromPointer:(SSDeferredFuncPtr)funcPtr;
/**
 * parameterIndex 传入为0时，实际参数最少为2 一个是self，一个是_cmd
 */
+ (SSDeferredFunc *)fromInvocation:(NSInvocation *)inv parameterIndex:(NSUInteger)i;
/**
 * 用自己的调用结果，调用下一个func
 */
- (SSDeferredFunc *)andThen:(SSDeferredFunc  *)other;
/*
 *用调用另一个func的结果，调用自己
 */
- (SSDeferredFunc *)composeWith:(SSDeferredFunc *)other;
@end
