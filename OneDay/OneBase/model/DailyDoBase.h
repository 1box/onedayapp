//
//  DailyDoBase.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "SSEntityBase.h"

#define kMakeDailyDoItemIDUserDefaultKey @"kMakeDailyDoItemIDUserDefaultKey"
static inline NSUInteger newDailyDoItemID() {
    NSUInteger makeID = [[NSUserDefaults standardUserDefaults] integerForKey:kMakeDailyDoItemIDUserDefaultKey] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:makeID forKey:kMakeDailyDoItemIDUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return makeID;
}

@class AddonData;
@class TodoData;
@class AlarmData;

@interface DailyDoBase : SSEntityBase

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSNumber *createTime; // eg. 978307200.0

@property (nonatomic, strong) AddonData *addon;
@property (nonatomic, strong) NSSet *tags;
@property (nonatomic, strong) NSSet *todos;

@property (nonatomic, readonly) NSNumber *check;

- (BOOL)isBlankDailyDo;

- (NSArray *)todosSortedByIndex;
- (NSArray *)todosSortedByStartTime;
- (TodoData *)todoForAlarm:(AlarmData *)alarm;

- (TodoData *)insertNewTodoAtIndex:(NSInteger)index;

/*!
 @return The second TodoData which been inserted.
 */
- (TodoData *)separateTodoAtIndex:(NSUInteger)index fromContentCharacterIndex:(NSUInteger)characterIndex;

- (BOOL)removeTodos:(NSArray *)todos;
- (BOOL)removeBlankTodos;

- (NSString *)todosTextWithLineNumber:(BOOL)withLineNumber;
- (NSUInteger)todoTextLengthFromIndex:(NSUInteger)start beforeIndex:(NSUInteger)end autoNumber:(BOOL)autoNumber;

- (BOOL)reorderTodos:(BOOL)save;
- (BOOL)detectTodos;

- (void)makeSnapshot;
- (BOOL)recoveryToSnapshot; // return NO if no snapshot or recovery failed

#pragma mark - protected
- (NSString *)presentedText;
- (NSString *)todayText;
- (NSString *)completionText;
@end
