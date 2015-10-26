//
//  DataListOperationManager.h
//  Essay
//
//  Created by Dianwei on 12-7-18.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDataOperation.h"

@interface ListDataOperationManager : NSObject

- (id)initWithOperations:(SSDataOperation*)operation,...;
- (void)insertOperation:(SSDataOperation*)operation atIndex:(int)index;
- (void)removeOperation:(SSDataOperation*)operation;
- (void)removeOperationAtIndex:(int)index;
- (int)operationCount;
- (void)addOperation:(SSDataOperation*)operation;
- (SSDataOperation*)operationAtIndex:(int)index;

- (void)startExecute:(id)operationContext;
@end
