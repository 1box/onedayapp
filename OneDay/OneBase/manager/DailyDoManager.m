//
//  DailyDoManager.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "AlarmManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "AlarmData.h"
#import "TodoData.h"
#import "KMDateUtils.h"
#import "SMDetector.h"

@implementation DailyDoManager

static DailyDoManager *_sharedManager;
+ (DailyDoManager *)sharedManager
{
    @synchronized(self) {
        if (_sharedManager == nil) {
            _sharedManager = [[DailyDoManager alloc] init];
        }
    }
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - Properties

- (NSArray *)propertiesForDoName:(NSString *)doName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:doName ofType:@"plist"];
    if (path) {
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
        return [root objectForKey:@"Properties"];
    }
    else {
        return nil;
    }
}

- (NSDictionary *)propertiesDictForProperties:(NSArray *)properties inDailyDo:(DailyDoBase *)dailyDo
{
    NSDictionary *properties_aps = [dailyDo properties_apsWithStopSuper:[DailyDoBase class]];
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    
    for (NSDictionary *property in properties) {
        NSString *name = [property objectForKey:kPropertyNameKey];
        id value = [properties_aps objectForKey:name];
        if (value) {
            [ret setObject:value forKey:name];
        }
    }
    
    return ret;
}

#pragma mark - Configurations

- (NSDictionary *)configurationsForDoName:(NSString *)doName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:doName ofType:@"plist"];
    if (path) {
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
        return [root objectForKey:@"Configurations"];
    }
    
    else {
        return nil;
    }
}

- (NSString *)sloganForDoName:(NSString *)doName
{
    NSString *tString = [[self configurationsForDoName:doName] objectForKey:kConfigurationSlogan];
    return NSLocalizedString(tString, nil);
}

- (NSArray *)inputHelperWordsForDoName:(NSString *)doName
{
    NSArray *tArray = [[self configurationsForDoName:doName] objectForKey:kConfigurationInputHelperWords];
    return tArray;
}

#pragma mark - DailyDos

- (BOOL)saveDailyDoWithAddon:(AddonData *)addon updateDictionary:(NSDictionary *)aDictionary
{
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    DailyDoBase *data = [DailyDoData insertEntityWithDictionary:aDictionary syncrhonizeWithStore:NO];
    data.addon = addon;
    return [[KMModelManager sharedManager] saveContext:nil];
}

- (void)moveDailyDoUndos:(DailyDoBase *)dailyDo toAnother:(DailyDoBase *)anotherDailyDo
{
    NSArray *todoList = [[dailyDo todosSortedByIndex] copy];
    int index = [anotherDailyDo.todos count] - 1;
    for (TodoData *todo in todoList) {
        if (![todo.check boolValue]) {
            todo.dailyDo = anotherDailyDo;
            todo.index = [NSNumber numberWithInt:index];
            
            index ++;
        }
    }
    
    [dailyDo reorderTodos:NO];
    [anotherDailyDo reorderTodos:NO];
    [[KMModelManager sharedManager] saveContext:nil];
}

- (id)tomorrowDoForAddon:(AddonData *)addon
{
    NSTimeInterval lessThan = [[[[NSDate date] dateByAddingDays:1] midnight] timeIntervalSince1970];
    NSTimeInterval greaterThanOrEqual = [[[[NSDate date] dateByAddingDays:1] morning] timeIntervalSince1970];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                 lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                          lessThanOrEqualQueries:nil
                                                              greaterThanQueries:nil
                                                       greaterThanOrEqualQueries:@{@"createTime" : [NSNumber numberWithDouble:greaterThanOrEqual]}
                                                                 notEqualQueries:nil
                                                               entityDescription:[DailyDoData entityDescription]
                                                                      unFaulting:NO
                                                                          offset:0
                                                                           count:1
                                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                           error:&error];
    
    DailyDoBase *dailyDo = nil;
    if (!error && [dailyDos count] > 0) {
        dailyDo = [dailyDos objectAtIndex:0];
    }
    else {
        dailyDo = [DailyDoData dataEntityWithInsert:YES];
        dailyDo.addon = addon;
        dailyDo.createTime = [NSNumber numberWithDouble:[[[NSDate date] dateByAddingDays:1] timeIntervalSince1970]];
        [[KMModelManager sharedManager] saveContext:nil];
    }
    
    return dailyDo;
}

- (id)todayDoForAddon:(AddonData *)addon
{
    NSTimeInterval lessThan = [[[NSDate date] midnight] timeIntervalSince1970];
    NSTimeInterval greaterThanOrEqual = [[[NSDate date] morning] timeIntervalSince1970];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                               lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                        lessThanOrEqualQueries:nil
                                                            greaterThanQueries:nil
                                                     greaterThanOrEqualQueries:@{@"createTime" : [NSNumber numberWithDouble:greaterThanOrEqual]}
                                                               notEqualQueries:nil
                                                             entityDescription:[DailyDoData entityDescription]
                                                                    unFaulting:NO
                                                                        offset:0
                                                                         count:1
                                                               sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                         error:&error];
    
    DailyDoBase *dailyDo = nil;
    if (!error && [dailyDos count] > 0) {
        dailyDo = [dailyDos objectAtIndex:0];
    }
    else {
        dailyDo = [DailyDoData dataEntityWithInsert:YES];
        dailyDo.addon = addon;
    }
    
    [self addAlarmDependedTodosForDailyDo:&dailyDo];
    [[KMModelManager sharedManager] saveContext:nil];
    
    return dailyDo;
}

- (NSArray *)loggedDosForAddon:(AddonData *)addon
{
    NSTimeInterval lessThan = [[[NSDate date] morning] timeIntervalSince1970];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                 lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                          lessThanOrEqualQueries:nil
                                                              greaterThanQueries:nil
                                                       greaterThanOrEqualQueries:nil
                                                                 notEqualQueries:nil
                                                               entityDescription:[DailyDoData entityDescription]
                                                                      unFaulting:NO
                                                                          offset:0
                                                                           count:NSIntegerMax
                                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                           error:&error];
    
    if (!error) {
        return dailyDos;
    }
    else {
        return nil;
    }
}

- (void)loadLoggedDosForCondition:(NSDictionary *)condition
{
    int count = [[condition objectForKey:kDailyDoManagerLoadConditionCountKey] intValue];
    BOOL isLoadMore = [[condition objectForKey:kDailyDoManagerLoadConditionIsLoadMoreKey] boolValue];
    AddonData *addon = [condition objectForKey:kDailyDoManagerLoadConditionAddonKey];
    
    NSTimeInterval lessThan = 0.f;
    if (isLoadMore) {
        lessThan = [[condition objectForKey:kDailyDoManagerLoadConditionMaxCreateTimeKey] doubleValue];
    }
    else {
        lessThan = [[[NSDate date] morning] timeIntervalSince1970];
    }
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                 lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                          lessThanOrEqualQueries:nil
                                                              greaterThanQueries:nil
                                                       greaterThanOrEqualQueries:nil
                                                                 notEqualQueries:nil
                                                               entityDescription:[DailyDoData entityDescription]
                                                                      unFaulting:NO
                                                                          offset:0
                                                                           count:count
                                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                           error:&error];
    
    NSMutableDictionary *mutUserInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *mutResult = [NSMutableDictionary dictionaryWithCapacity:5];
    if (!error) {
        [mutResult setObject:dailyDos forKey:kDailyDoManagerLoadResultDataListKey];
    }
    else {
        [mutResult setObject:error forKey:kDailyDoManagerLoadResultErrorKey];
    }
    
    [mutUserInfo setObject:[mutResult copy] forKey:kDailyDoManagerLoggedLoadResultKey];
    [mutUserInfo setObject:condition forKey:kDailyDoManagerLoggedDosLoadConditionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DailyDoManagerLoggedDosLoadFinishedNotification object:self userInfo:[mutUserInfo copy]];
}

// monthlyDos
- (NSArray *)monthlyDosForAddon:(AddonData *)addon year:(NSDate *)year
{
    NSMutableArray *mutMonthlyDos = [NSMutableArray arrayWithCapacity:12];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSNumber *lessThan = [NSNumber numberWithDouble:[[[NSDate date] endOfYear] timeIntervalSince1970]];
    NSNumber *greaterThanOrEqual = [NSNumber numberWithDouble:[[[NSDate date] beginningOfYear] timeIntervalSince1970]];
    
    NSError *error = nil;
    NSArray *results = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                lessThanQueries:@{@"createTime" : lessThan}
                                                         lessThanOrEqualQueries:nil
                                                             greaterThanQueries:nil
                                                      greaterThanOrEqualQueries:@{@"createTime": greaterThanOrEqual}
                                                                notEqualQueries:nil
                                                              entityDescription:[DailyDoData entityDescription]
                                                                     unFaulting:NO
                                                                         offset:0
                                                                          count:NSIntegerMax
                                                                sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                          error:&error];
    
    if (!error && [results count] > 0) {
        __block NSDate *lastDate = [NSDate date];
        __block MonthlyDo *currentMonthDo = [[MonthlyDo alloc] init];
        __block CGFloat summary = 0.f;
        currentMonthDo.currentMonth = [NSDate date];
        
        NSMutableArray *dailyDosInMonth = [NSMutableArray arrayWithCapacity:35];
        
        [results enumerateObjectsUsingBlock:^(DailyDoBase *dailyDo, NSUInteger idx, BOOL *stop) {
            
            NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[dailyDo.createTime doubleValue]];
            if ([lastDate isSameMonthAsDate:createDate]) {
                [dailyDosInMonth addObject:dailyDo];
                for (TodoData *todo in dailyDo.todos) {
                    summary += [[[SMDetector defaultDetector] valueInString:todo.money byType:SmarkDetectTypeMoney] floatValue];
                }
            }
            else {
                currentMonthDo.dailyDos = [dailyDosInMonth copy];
                currentMonthDo.summary = summary;
                [mutMonthlyDos addObject:currentMonthDo];
                
                [dailyDosInMonth removeAllObjects];
                summary = 0.f;
                
                [dailyDosInMonth addObject:dailyDo];
                for (TodoData *todo in dailyDo.todos) {
                    summary += [[[SMDetector defaultDetector] valueInString:todo.money byType:SmarkDetectTypeMoney] floatValue];
                }
                
                currentMonthDo = [[MonthlyDo alloc] init];
                currentMonthDo.currentMonth = createDate;
            }
            
            lastDate = createDate;
        }];
        
        if ([mutMonthlyDos lastObject] != currentMonthDo && [dailyDosInMonth count] > 0) {
            currentMonthDo.dailyDos = [dailyDosInMonth copy];
            currentMonthDo.summary = summary;
            [mutMonthlyDos addObject:currentMonthDo];
        }
    }
    
    NSArray *monthDos = [mutMonthlyDos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"currentMonth" ascending:YES]]];
    return monthDos;
}

// yearlyDos
- (NSArray *)yearlyDosForAddon:(AddonData *)addon
{
    NSMutableArray *mutYearlyDos = [NSMutableArray arrayWithCapacity:12];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *results = [[KMModelManager sharedManager] entitiesWithQuery:nil
                                                       entityDescription:[DailyDoData entityDescription]
                                                              unFaulting:NO
                                                                  offset:0
                                                                   count:NSIntegerMax
                                                         sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                   error:&error];
    
    if (!error && [results count] > 0) {
        __block NSDate *lastDate = [NSDate date];
        __block YearlyDo *currentYearDo = [[YearlyDo alloc] init];
        __block CGFloat summary = 0.f;
        currentYearDo.currentYear = [NSDate date];
        
        NSMutableArray *dailyDosInYear = [NSMutableArray arrayWithCapacity:35];
        
        [results enumerateObjectsUsingBlock:^(DailyDoBase *dailyDo, NSUInteger idx, BOOL *stop) {
            
            NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[dailyDo.createTime doubleValue]];
            if ([lastDate isSameYearAsDate:createDate]) {
                [dailyDosInYear addObject:dailyDo];
                for (TodoData *todo in dailyDo.todos) {
                    summary += [[[SMDetector defaultDetector] valueInString:todo.money byType:SmarkDetectTypeMoney] floatValue];
                }
            }
            else {
                currentYearDo.dailyDos = [dailyDosInYear copy];
                currentYearDo.summary = summary;
                [mutYearlyDos addObject:currentYearDo];
                
                [dailyDosInYear removeAllObjects];
                [dailyDosInYear addObject:dailyDo];
                for (TodoData *todo in dailyDo.todos) {
                    summary += [[[SMDetector defaultDetector] valueInString:todo.money byType:SmarkDetectTypeMoney] floatValue];
                }
                
                currentYearDo = [[YearlyDo alloc] init];
                currentYearDo.currentYear = createDate;
            }
            
            lastDate = createDate;
        }];
        
        if ([mutYearlyDos lastObject] != currentYearDo && [dailyDosInYear count] > 0) {
            currentYearDo.dailyDos = [dailyDosInYear copy];
            currentYearDo.summary = summary;
            [mutYearlyDos addObject:currentYearDo];
        }
    }
    
    return [mutYearlyDos copy];
}

#pragma mark - private

- (void)addAlarmDependedTodosForDailyDo:(DailyDoBase **)dailyDo
{
    if (autoAddOpenAlarmsToDailyDo()) {
        NSArray *alarms = [[AlarmManager sharedManager] openAlarmsForAddon:(*dailyDo).addon];
        
        int index = 0;
        for (AlarmData *alarm in alarms) {
            TodoData *todo = [(*dailyDo) todoForAlarm:alarm];
            if (!todo && [alarm needAlarmToday]) {
                todo = [(*dailyDo) insertNewTodoAtIndex:index];
                [todo updateWithAlarm:alarm save:NO];
                index ++;
            }
        }
    }
}

@end


@implementation MonthlyDo
@end


@implementation YearlyDo
@end
