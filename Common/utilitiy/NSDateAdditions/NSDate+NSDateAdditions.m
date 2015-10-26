//
//  NSDate+NSDateAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSDate+NSDateAdditions.h"
#import "KMDateUtils.h"

@implementation NSDate (NSDateAdditions)

static unsigned _unitFlags = (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit);

+ (NSDate *)currentTimeTomorrow
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.day += 1;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

+ (NSDate *)currentTimeAfterDay:(NSInteger)days
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.day += days;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

//- (BOOL)isToday
//{
//    NSDate *today = beginningOfToday();
//    NSDate *tomorrow = beginningOfTomorrow();
//    
//    NSDate *ealier = [self earlierDate:tomorrow];
//    NSDate *later = [self laterDate:today];
//    
//    return later == self && ealier == self;
//}
//
//- (BOOL)isTomorrow
//{
//    NSDate *tomorrow = beginningOfTomorrow();
//    NSDate *beginningtheDayAftertomorrow = nil;
//    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginningtheDayAftertomorrow interval:NULL forDate:[NSDate currentTimeAfterDay:2]];
//    
//    if (ok) {
//        NSDate *ealier = [self earlierDate:beginningtheDayAftertomorrow];
//        NSDate *later = [self laterDate:tomorrow];
//        return later == self && ealier == self;
//    }
//    else {
//        return NO;
//    }
//}

- (NSDateFormatter *)yearToDayFormatter
{
    static NSDateFormatter *yearToDayFormatter_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!yearToDayFormatter_) {
            yearToDayFormatter_ = [[NSDateFormatter alloc] init];
            [yearToDayFormatter_ setLocale:[NSLocale currentLocale]];
            [yearToDayFormatter_ setDateFormat:@"yyyy.MM.dd"];
        }
    });
    return yearToDayFormatter_;
}

- (NSDate *)morning
{
    NSDateFormatter *dateFormatter = [self yearToDayFormatter];
    return [dateFormatter dateFromString:[dateFormatter stringFromDate:self]];
}

- (NSDate *)midnight
{
    NSTimeInterval interval = [self timeIntervalSince1970];
    interval += 24*60*60;
    NSDate *tomorrow = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [self yearToDayFormatter];
    return [dateFormatter dateFromString:[dateFormatter stringFromDate:tomorrow]];
}

- (BOOL)isSameDayWithDate:(NSDate *)date
{
    NSDate *ealier = [date earlierDate:[self midnight]];
    NSDate *later = [date laterDate:[self morning]];
    return (ealier == date && later == date);
}

- (NSDate *)sameTimeToday
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:self];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.year = todayComponents.year;
    components.month = todayComponents.month;
    components.day = todayComponents.day;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

//- (NSDate *)sameTimeTomorrow
//{
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:self];
//    NSDateComponents *tComponents = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
//    components.year = tComponents.year;
//    components.month = tComponents.month;
//    components.day = tComponents.day + 1;
//    return [[NSCalendar currentCalendar] dateFromComponents:components];
//}
@end
