//
//  DailyDoBase.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoBase.h"
#import "KMModelManager.h"
#import "AddonData.h"
#import "TodoData.h"
#import "SMDetector.h"
#import "SMConstants.h"
#import "DailyDoManager.h"

@implementation DailyDoBase

@dynamic itemID;
@dynamic createTime;
@dynamic tags;
@dynamic addon;
@dynamic todos;

@synthesize check;

+ (NSString *)entityName
{
    return @"DailyDoBase";
}

+ (NSArray *)primaryKeys
{
    return @[@"itemID", @"addon.dailyDoName"];
}

+ (NSDictionary *)keyMapping
{
    return @{
    @"itemID" : @"item_id",
    @"createTime" : @"create_time",
    @"todayDate" : @"today_date",
    @"tags" : @"tags",
    };
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    DailyDoBase *dailyDo = [[[self class] alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext:insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
    dailyDo.itemID = [NSNumber numberWithInteger:newDailyDoItemID()];
    dailyDo.createTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    
    return dailyDo;
}

#pragma mark - getter

- (NSNumber *)check
{
    if (![self.addon.showChecked boolValue]) {
        return @YES;
    }
    
    BOOL dailyDoChecked = [self.todos count] != 0;
    for (TodoData *tmpTodo in self.todos) {
        dailyDoChecked &= [tmpTodo.check boolValue];
    }
    return [NSNumber numberWithBool:dailyDoChecked];
}

- (BOOL)isBlankDailyDo
{
    return [self.todos count] == 0 && ![[NSDate dateWithTimeIntervalSince1970:[self.createTime integerValue]] isToday];
}

#pragma mark - get todos

- (NSArray *)todosSortedByIndex
{
    return [self.todos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
}

- (NSArray *)todosSortedByStartTime
{
    return [self.todos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES]]];
}

- (TodoData *)todoForAlarm:(AlarmData *)alarm
{
    TodoData *ret = nil;
    for (TodoData *todo in self.todos) {
        if (todo.alarm == alarm) {
            ret = todo;
        }
    }
    return ret;
}

#pragma mark - insert&delete todos

- (TodoData *)insertNewTodoAtIndex:(NSInteger)index
{
    for (TodoData *tmpTodo in self.todos) {
        if ([tmpTodo.index intValue] >= index) {
            tmpTodo.index = [NSNumber numberWithInt:[tmpTodo.index intValue] + 1];
        }
        else if ([tmpTodo.index intValue] == index - 1) {
            if (![tmpTodo.content hasSuffix:SMSeparator]) {
                tmpTodo.content = [NSString stringWithFormat:@"%@%@", tmpTodo.content, SMSeparator];
            }
        }
    }
    
    TodoData *todo = [TodoData insertEntityWithDictionary:@{@"index" : [NSNumber numberWithInteger:index]} syncrhonizeWithStore:NO];
    todo.dailyDo = self;
//    self.check = @NO;
    return todo;
}

- (TodoData *)separateTodoAtIndex:(NSUInteger)index fromContentCharacterIndex:(NSUInteger)characterIndex
{
    TodoData *separatedTodo = [[self todosSortedByIndex] objectAtIndex:index];
    NSString *firstHalfPart = [separatedTodo.content substringToIndex:characterIndex];
    NSString *secondHalfPart = [separatedTodo.content substringFromIndex:characterIndex];
    
    separatedTodo.content = [NSString stringWithFormat:@"%@%@", firstHalfPart, SMSeparator];
    
    TodoData *insertTodo = [self insertNewTodoAtIndex:index + 1];
    insertTodo.content = secondHalfPart;
    [[KMModelManager sharedManager] saveContext:nil];
    
    return insertTodo;
}

- (BOOL)removeTodos:(NSArray *)todos
{
    if ([todos count] > 0) {
        
        BOOL ret = [[KMModelManager sharedManager] removeEntities:todos error:nil];
        if (ret) {
            NSArray *tmpTodos = [self todosSortedByIndex];
            [tmpTodos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop){
                todo.index = [NSNumber numberWithInt:idx];
            }];
            ret = [[KMModelManager sharedManager] saveContext:nil];
        }
        return ret;
    }
    else {
        return NO;
    }
}

- (BOOL)removeBlankTodos
{
    NSMutableArray *blankTodos = [NSMutableArray array];
    for (TodoData *tmpTodo in self.todos) {
        if ([tmpTodo.content length] == 0 || [tmpTodo.content isEqualToString:SMSeparator]) {
            [blankTodos addObject:tmpTodo];
        }
    }
    
    if ([blankTodos count] > 0) {
        return [self removeTodos:blankTodos];
    }
    else {
        return YES;
    }
}

#pragma mark - manage todos's property

- (NSString *)todosTextWithLineNumber:(BOOL)withLineNumber
{
    NSArray *todos = [self todosSortedByIndex];
    if ([todos count] > 0) {
        __block NSMutableString *todoText = [NSMutableString string];
        [todos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
            if (withLineNumber) {
                [todoText appendFormat:@"%d. %@", idx + 1, todo.content];
            }
            else {
                [todoText appendFormat:@"%@", todo.content];
            }
        }];
        return [todoText copy];
    }
    else {
        return @"";
    }
}

- (NSUInteger)todoTextLengthFromIndex:(NSUInteger)start beforeIndex:(NSUInteger)end autoNumber:(BOOL)autoNumber
{
    NSUInteger ret = 0;
    
    NSArray *todos = [self todosSortedByIndex];
    NSUInteger index = 0;
    for (index = start; index < end; index++) {
        TodoData *todo = [todos objectAtIndex:index];
        ret += [todo.content length];
        
        if (autoNumber) {
            ret += [todo lineNumberStringLength];
        }
    }
    return ret;
}

- (BOOL)reorderTodos:(BOOL)save
{
    NSArray *todos = [self todosSortedByIndex];
    NSUInteger index = 0;
    for (index = 0; index < [todos count]; index++) {
        TodoData *todo = [todos objectAtIndex:index];
        todo.index = [NSNumber numberWithInt:index];
        
        if(index == [todos count] - 1) {
            if([todo.content hasSuffix:SMSeparator]) {
                NSMutableString *tString = [todo.content mutableCopy];
                [tString deleteCharactersInRange:NSMakeRange([tString length] - [SMSeparator length], [SMSeparator length])];
                todo.content = [tString copy];
            }
        }
        else {
            if(![todo.content hasSuffix:SMSeparator]) {
                todo.content = [NSString stringWithFormat:@"%@%@", todo.content, SMSeparator];
            }
        }
    }
    
    if (save) {
        return [[KMModelManager sharedManager] saveContext:nil];
    }
    else {
        return YES;
    }
}

- (BOOL)detectTodos
{
    NSString *firstStartTime = DefaultFirstStartTime;
    NSNumber *duration = [NSNumber numberWithInt:DefaultTodoDuration];
    
    for (TodoData *todo in [self todosSortedByIndex]) {
        NSArray *dates = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeDate];
        if ([dates count] > 0) {
            firstStartTime = [[TodoData startTimeDateFormmatter] stringFromDate:((NSDate*)[dates objectAtIndex:0])];
        }
        todo.startTime = firstStartTime;
        
        NSArray *durations = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeDuration];
        if ([durations count]) {
            duration = [durations objectAtIndex:0];
        }
        todo.duration = duration;
        
        NSDate *tmpStartDate = [NSDate dateWithTimeIntervalSince1970:[[[TodoData startTimeDateFormmatter] dateFromString:firstStartTime] timeIntervalSince1970] + [duration intValue] + DefaultTodoTimeInterval];
        firstStartTime = [[TodoData startTimeDateFormmatter] stringFromDate:tmpStartDate];
    }
    
    NSInteger detectType = [self.addon.detectType integerValue];
    if ((detectType & SmarkDetectTypeMoney) == SmarkDetectTypeMoney) {
        for (TodoData *todo in [self todosSortedByIndex]) {
            NSArray *moneys = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeMoney];
            if ([moneys count] > 0) {
                todo.money = [moneys objectAtIndex:0];
            }
            else {
                todo.money = nil;
            }
        }
    }
    
    if ((detectType & SmarkDetectTypeCaloric) == SmarkDetectTypeCaloric) {
        for (TodoData *todo in [self todosSortedByIndex]) {
            NSArray *calorics = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeCaloric];
            if ([calorics count] > 0) {
                todo.caloric = [calorics objectAtIndex:0];
            }
            else {
                todo.caloric = nil;
            }
        }
    }
    
    if ((detectType & SmarkDetectTypeDistance) == SmarkDetectTypeDistance) {
        for (TodoData *todo in [self todosSortedByIndex]) {
            NSArray *distances = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeDistance];
            if ([distances count] > 0) {
                todo.distance = [distances objectAtIndex:0];
            }
            else {
                todo.distance = nil;
            }
        }
    }
    
    if ((detectType & SmarkDetectTypeFrequency) == SmarkDetectTypeFrequency) {
        for (TodoData *todo in [self todosSortedByIndex]) {
            NSArray *frequencies = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeFrequency];
            if ([frequencies count] > 0) {
                todo.frequency = [frequencies objectAtIndex:0];
            }
            else {
                todo.frequency = nil;
            }
        }
    }
    
    if ((detectType & SmarkDetectTypeQuantity) == SmarkDetectTypeQuantity) {
        for (TodoData *todo in [self todosSortedByIndex]) {
            NSArray *quantities = [[SMDetector defaultDetector] itemInString:todo.content byType:SmarkDetectTypeQuantity];
            if ([quantities count] > 0) {
                todo.quantity = [quantities objectAtIndex:0];
            }
            else {
                todo.quantity = nil;
            }
        }
    }
    
    BOOL ret = [[KMModelManager sharedManager] saveContext:nil];
    if (!ret) {
        SSLog(@"Error occurs when save detected time and duration!");
    }
    return ret;
}

#pragma mark - snapshot

static NSArray *__snapshotTodos = nil;
- (void)makeSnapshot
{
    NSArray *todos = [self todosSortedByIndex];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[todos count]];
    for (TodoData *tmpTodo in todos) {
        [tmpArray addObject:@{
         @"index" : tmpTodo.index,
         @"item_id" : tmpTodo.itemID,
         @"start_time" : tmpTodo.startTime ? tmpTodo.startTime : @"",
         @"duration" : tmpTodo.duration ? tmpTodo.duration : @0,
         @"check" : tmpTodo.check ? tmpTodo.check : @NO,
         @"content" : KMEmptyString(tmpTodo.content) ? @"" : tmpTodo.content,
         }];
    }
    __snapshotTodos = [tmpArray copy];
}

- (BOOL)recoveryToSnapshot
{
    if (__snapshotTodos) {
        [self removeTodos:[self todosSortedByIndex]];
        for (NSDictionary *tmpTodoDict in __snapshotTodos) {
            TodoData *todo = [TodoData insertEntityWithDictionary:tmpTodoDict syncrhonizeWithStore:NO];
            todo.dailyDo = self;
        }
        return [[KMModelManager sharedManager] saveContext:nil];
    }
    else {
        return NO;
    }
}

#pragma mark - protected

- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)todayText
{
    NSString *tString = [[[DailyDoManager sharedManager] configurationsForDoName:self.addon.dailyDoName] objectForKey:kConfigurationSlogan];
    return NSLocalizedString(tString, nil);
}

- (NSString *)completionText
{
    if ([self.addon.showChecked boolValue]) {
        
        int checkedTodoCount = 0;
        for (TodoData *todo in self.todos) {
            if ([todo.check boolValue]) {
                checkedTodoCount ++;
            }
        }
        return [NSString stringWithFormat:@"%0.2f%@", [self.todos count] == 0 ? 0.0 : ((float)checkedTodoCount/[self.todos count])*100, @"%"];
    }
    else {
        return @"";
    }
}
@end
