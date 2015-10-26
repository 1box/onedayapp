//
//  TodoManager.h
//  OneDay
//
//  Created by Kimimaro on 13-5-12.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TodoManagerUndosLoadFinishedNotification @"TodoManagerUndosLoadFinishedNotification"
#define kTodoManagerUndosLoadConditionKey @"kTodoManagerUndosLoadConditionKey"
#define kTodoManagerUndosLoadResultKey @"kTodoManagerUndosLoadResultKey"

#define kTodoManagerLoadConditionMaxCreateTimeKey @"kTodoManagerLoadConditionMaxCreateTimeKey"
#define kTodoManagerLoadConditionCountKey @"kTodoManagerLoadConditionCountKey"
#define kTodoManagerLoadConditionIsLoadMoreKey @"kTodoManagerLoadConditionIsLoadMoreKey"
#define kTodoManagerLoadConditionAddonKey @"kTodoManagerLoadConditionAddonKey"

#define kTodoManagerLoadResultDataListKey @"kTodoManagerLoadResultDataListKey"
#define kTodoManagerLoadResultErrorKey @"kTodoManagerLoadResultErrorKey"

@class AddonData;

@interface TodoManager : NSObject

+ (TodoManager *)sharedManager;
- (void)loadUndosForCondition:(NSDictionary *)condition;

@end
