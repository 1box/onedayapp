//
//  AlarmData.m
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmData.h"
#import "AddonData.h"
#import "KMModelManager.h"
#import "KMDateUtils.h"

@implementation AlarmData

@dynamic itemID;
@dynamic alarmTime;
@dynamic text;
@dynamic open;
@dynamic type;
@dynamic repeatType;
@dynamic addon;
@dynamic todos;

+ (NSString *)entityName
{
    return @"AlarmData";
}

+ (NSArray *)primaryKeys
{
    return @[@"itemID"];
}

+ (NSDictionary *)keyMapping
{
    return @{
             @"alarmTime" : @"alarm_time",
             @"text" : @"text",
             @"open" : @"open",
             @"type" : @"type"
             };
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    AlarmData *tAlarm = [[self alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext:insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
    tAlarm.itemID = [NSNumber numberWithInteger:newAlarmItemID()];
    tAlarm.open = @YES;
    tAlarm.type = [NSNumber numberWithInteger:AlarmNagTypeGentle];
    tAlarm.repeatType = [NSNumber numberWithInt:(AlarmRepeatTypeSunday|AlarmRepeatTypeMonday|AlarmRepeatTypeTuesday|AlarmRepeatTypeWednesday|AlarmRepeatTypeThursday|AlarmRepeatTypeFriday|AlarmRepeatTypeSaturday)];
    tAlarm.text = NSLocalizedString(@"AlarmDataDefaultText", nil);
    return tAlarm;
}

#pragma mark - public

- (NSString *)nagTypeText
{
    NSString *ret = @"";
    AlarmNagType nagType = [self.type integerValue];
    switch (nagType) {
        case AlarmNagTypeGentle:
            ret = NSLocalizedString(@"AlarmNagTypeGentle", nil);
            break;
            case AlarmNagTypeNag:
            ret = NSLocalizedString(@"AlarmNagTypeNag", nil);
            break;
            
        default:
            break;
    }
    return ret;
}

- (NSString *)repeatText
{
    AlarmRepeatType repeatType = [self.repeatType integerValue];
    
    if (repeatType == (AlarmRepeatTypeSunday|AlarmRepeatTypeMonday|AlarmRepeatTypeTuesday|AlarmRepeatTypeWednesday|AlarmRepeatTypeThursday|AlarmRepeatTypeFriday|AlarmRepeatTypeSaturday)) {
        return NSLocalizedString(@"AlarmRepeatTypeEveryDay", nil);
    }
    else if (repeatType == (AlarmRepeatTypeMonday|AlarmRepeatTypeTuesday|AlarmRepeatTypeWednesday|AlarmRepeatTypeThursday|AlarmRepeatTypeFriday)) {
        return NSLocalizedString(@"AlarmRepeatTypeWorkday", nil);
    }
    else if (repeatType == AlarmRepeatTypeNever) {
        return NSLocalizedString(@"AlarmRepeatTypeNone", nil);
    }
    else {
        NSMutableString *repeatText = [NSMutableString stringWithCapacity:50];
        
        if (AlarmRepeatTypeSunday == (AlarmRepeatTypeSunday&repeatType)) {
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:0]];
        }
        
        if (AlarmRepeatTypeMonday == (AlarmRepeatTypeMonday&repeatType)) {
            if ([repeatText length] > 0) {
                [repeatText appendString:@" "];
            }
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:1]];
        }
        
        if (AlarmRepeatTypeTuesday == (AlarmRepeatTypeTuesday&repeatType)) {
            if ([repeatText length] > 0) {
                [repeatText appendString:@" "];
            }
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:2]];
        }
        
        if (AlarmRepeatTypeWednesday == (AlarmRepeatTypeWednesday&repeatType)) {
            if ([repeatText length] > 0) {
                [repeatText appendString:@" "];
            }
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:3]];
        }
        
        if (AlarmRepeatTypeThursday == (AlarmRepeatTypeThursday&repeatType)) {
            if ([repeatText length] > 0) {
                [repeatText appendString:@" "];
            }
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:4]];
        }
        
        if (AlarmRepeatTypeFriday == (AlarmRepeatTypeFriday&repeatType)) {
            if ([repeatText length] > 0) {
                [repeatText appendString:@" "];
            }
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:5]];
        }
        
        if (AlarmRepeatTypeSaturday == (AlarmRepeatTypeSaturday&repeatType)) {
            if ([repeatText length] > 0) {
                [repeatText appendString:@" "];
            }
            [repeatText appendString:[[HourToMiniteFormatter() shortWeekdaySymbols] objectAtIndex:6]];
        }
        return [repeatText copy];
    }
}

- (NSArray *)nextRepeatTimes
{
    NSDate *alarmDate = [[HourToMiniteFormatter() dateFromString:self.alarmTime] sameTimeToday];
    AlarmRepeatType repeatType = [self.repeatType integerValue];
    if (repeatType == AlarmRepeatTypeNever) {
        return nil;
    }
    
    AlarmRepeatType todayRepeatType = [AlarmData repeatTypeAfterDays:0];
    
    NSDate *nextRepeatTime = [NSDate date];
    if (([alarmDate laterDate:[NSDate date]] == alarmDate) && (todayRepeatType == (repeatType&todayRepeatType))) {
        nextRepeatTime = alarmDate;
    }
    else {
        AlarmRepeatType nextRepeatType = AlarmRepeatTypeNever;
        for (int i=1; i<=7; i++) {
            nextRepeatType = [AlarmData repeatTypeAfterDays:i];
            if (nextRepeatType == (nextRepeatType&repeatType)) {
                break;
            }
        }
        
        NSInteger days = ([AlarmData weekdayForRepeatType:nextRepeatType] - [[NSDate date] weekday] + 7)%7;
        nextRepeatTime = [alarmDate dateByAddingDays:days];
    }
    
    NSMutableArray *mutRepeatTimes = [NSMutableArray arrayWithCapacity:5];
    [mutRepeatTimes addObject:nextRepeatTime];
    
    if (AlarmNagTypeNag == [self.type integerValue]) {
        for (int i=0; i<5; i++) {
            nextRepeatTime = [nextRepeatTime dateByAddingMinutes:(5 - i)];
            [mutRepeatTimes addObject:nextRepeatTime];
        }
    }
    
    return [mutRepeatTimes copy];
}

- (BOOL)needAlarmToday
{
    AlarmRepeatType todayRepeatType = [AlarmData repeatTypeAfterDays:0];
    return (todayRepeatType == ([self.repeatType integerValue]&todayRepeatType));
}

#pragma mark - private

+ (AlarmRepeatType)repeatTypeAfterDays:(NSInteger)days
{
    AlarmRepeatType ret = AlarmRepeatTypeNever;
    NSDate *date = [[NSDate date] dateByAddingDays:days];
    switch ([date weekday]) {
        case 1:
            ret = AlarmRepeatTypeSunday;
            break;
        case 2:
            ret = AlarmRepeatTypeMonday;
            break;
        case 3:
            ret = AlarmRepeatTypeTuesday;
            break;
        case 4:
            ret = AlarmRepeatTypeWednesday;
            break;
        case 5:
            ret = AlarmRepeatTypeThursday;
            break;
        case 6:
            ret = AlarmRepeatTypeFriday;
            break;
        case 7:
            ret = AlarmRepeatTypeSaturday;
            break;
            
        default:
            break;
    }
    return ret;
}

+ (NSInteger)weekdayForRepeatType:(AlarmRepeatType)repeatType
{
    NSInteger weekday = 0;
    switch (repeatType) {
        case AlarmRepeatTypeSunday:
            weekday = 1;
            break;
        case AlarmRepeatTypeMonday:
            weekday = 2;
            break;
        case AlarmRepeatTypeTuesday:
            weekday = 3;
            break;
        case AlarmRepeatTypeWednesday:
            weekday = 4;
            break;
        case AlarmRepeatTypeThursday:
            weekday = 5;
            break;
        case AlarmRepeatTypeFriday:
            weekday = 6;
            break;
        case AlarmRepeatTypeSaturday:
            weekday = 7;
            break;
            
        default:
            break;
    }
    return weekday;
}

@end
