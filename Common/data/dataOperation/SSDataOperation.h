//
//  SSDataOperation.h
//  Essay
//
//  Created by Dianwei on 12-7-10.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^shouldExecute)(id operationContext);
typedef void(^didFinished)(NSArray *newList, NSError *error,  id operationContext);

@interface SSDataOperation : NSObject



- (void)execute:(id)operationContext;
- (void)cancel;
- (void)notifyWithData:(NSArray*)newlistData error:(NSError*)error userInfo:(NSDictionary*)userInfo;
- (void)executeNext:(id)operationContext;

@property(nonatomic, assign)BOOL hasFinished;
@property(nonatomic, copy)shouldExecute shouldExecuteBlock;
@property(nonatomic, copy)didFinished didFinishedBlock;
@property(nonatomic, assign)SSDataOperation *nextOperation;
@property(nonatomic, readonly)BOOL cancelled;

@end
