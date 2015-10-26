//
//  TodoData.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TodoData.h"
#import "DailyDoBase.h"
#import "AlarmData.h"
#import "KMModelManager.h"
#import "SMConstants.h"
#import "KMDateUtils.h"
//#import "GCCalendar.h"

@implementation TodoData

@dynamic itemID;
@dynamic index;
@dynamic startTime;
@dynamic eventColor;
@dynamic duration;
@dynamic location;
@dynamic check;
@dynamic content;
@dynamic money;
@dynamic caloric;
@dynamic distance;
@dynamic frequency;
@dynamic quantity;
@dynamic dailyDo;
@dynamic alarm;

+ (NSString *)entityName
{
    return @"TodoData";
}

+ (NSArray *)primaryKeys
{
    return @[@"itemID"];
}

+ (NSDictionary *)keyMapping
{
    return @{
    @"itemID" : @"item_id",
    @"index" : @"index",
    @"startTime" : @"start_time",
    @"eventColor" : @"event_color",
    @"duration" : @"duration",
    @"location" : @"location",
    @"content" : @"content",
    };
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    TodoData *todo = [[[self class] alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext:insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
    todo.itemID = [NSNumber numberWithInteger:newToDoItemID()];
    todo.check = @NO;
//    todo.eventColor = [[GCCalendar colors] objectAtIndex:arc4random()%GCCalendarColorCount];
    
    return todo;
}

+ (NSDateFormatter *)startTimeDateFormmatter
{
    return HourToMiniteFormatter();
}

- (void)updateWithAlarm:(AlarmData *)alarm save:(BOOL)save
{
    self.alarm = alarm;
    self.startTime = alarm.alarmTime;
    self.duration = [NSNumber numberWithInt:DefaultTodoDuration];
    self.content = [NSString stringWithFormat:@"%@ %@\n", alarm.text, alarm.alarmTime];
    
    if (save) {
        [[KMModelManager sharedManager] saveContext:nil];
    }
}

- (NSUInteger)lineNumberStringLength
{
    return [[NSString stringWithFormat:@"%d. ", [self.index intValue] + 1] length];
}

- (NSString *)lineNumberString
{
    return [NSString stringWithFormat:@"%d. ", [self.index intValue] + 1];
}

- (NSString *)pureContent
{
    return [self.content stringByReplacingOccurrencesOfString:SMSeparator withString:@""];
}

- (NSString *)timelineContent
{
    NSMutableString *tStr = [NSMutableString stringWithString:self.content];
//    if (!KMEmptyString(self.money)) {
//        [tStr appendFormat:@" %@", self.money];
//    }
//
//    if (!KMEmptyString(self.caloric)) {
//        [tStr appendFormat:@" %@", self.caloric];
//    }
//
//    if (!KMEmptyString(self.distance)) {
//        [tStr appendFormat:@" %@", self.distance];
//    }
//
//    if (!KMEmptyString(self.frequency)) {
//        [tStr appendFormat:@" %@", self.frequency];
//    }
//    
//    if (!KMEmptyString(self.quantity)) {
//        [tStr appendFormat:@" %@", self.quantity];
//    }
    return [tStr copy];
}

- (NSDate *)dateForStartTime
{
    return [[TodoData startTimeDateFormmatter] dateFromString:self.startTime];
}
@end
