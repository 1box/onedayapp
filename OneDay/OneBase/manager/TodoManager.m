//
//  TodoManager.m
//  OneDay
//
//  Created by Kimimaro on 13-5-12.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "TodoManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "KMModelManager.h"

@implementation TodoManager

static TodoManager *_sharedManager = nil;
+ (TodoManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc a second instance for a singleton.");
    return [super alloc];
}

- (void)loadUndosForCondition:(NSDictionary *)condition
{
    AddonData *addon = [condition objectForKey:kTodoManagerLoadConditionAddonKey];
    
    NSDictionary *lessThanQuery = nil;
    NSDictionary *greaterThanQuery = nil;
    BOOL isLoadMore = [[condition objectForKey:kTodoManagerLoadConditionIsLoadMoreKey] boolValue];
    if (isLoadMore) {
        lessThanQuery = @{@"dailyDo.createTime" : [condition objectForKey:kTodoManagerLoadConditionMaxCreateTimeKey]};
    }
    else {
        greaterThanQuery = @{@"dailyDo.createTime" : @0};
    }
    
    NSInteger count = [[condition objectForKey:kTodoManagerLoadConditionCountKey] integerValue];
    
    NSError *error = nil;
    NSArray *results = [[KMModelManager sharedManager] entitiesWithEqualQueries:@{@"dailyDo.addon.dailyDoName" : addon.dailyDoName, @"check" : @NO}
                                                                lessThanQueries:lessThanQuery
                                                         lessThanOrEqualQueries:nil
                                                             greaterThanQueries:greaterThanQuery
                                                      greaterThanOrEqualQueries:nil
                                                                notEqualQueries:nil
                                                              entityDescription:[TodoData entityDescription]
                                                                     unFaulting:YES
                                                                         offset:0
                                                                          count:count
                                                                sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dailyDo.createTime" ascending:NO]]
                                                                          error:&error];
    NSMutableDictionary *mutUserInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *mutResult = [NSMutableDictionary dictionaryWithCapacity:5];
    if (!error) {
        [mutResult setObject:results forKey:kTodoManagerLoadResultDataListKey];
    }
    else {
        [mutResult setObject:error forKey:kTodoManagerLoadResultErrorKey];
    }
    
    [mutUserInfo setObject:[mutResult copy] forKey:kTodoManagerUndosLoadResultKey];
    [mutUserInfo setObject:condition forKey:kTodoManagerUndosLoadConditionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TodoManagerUndosLoadFinishedNotification object:self userInfo:[mutUserInfo copy]];
}

@end
