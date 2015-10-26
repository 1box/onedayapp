//
//  KMDateUtils.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#ifndef OneDay_KMDateUtils_h
#define OneDay_KMDateUtils_h

#import "NSDate+NSDateAdditions.h"

// calendar

#define SecondPerDay (60*60*24)
#define SecondPerHour (60*60)
#define SecondPerMinute 60

#define ENUSLocaleString @"en_US"
#define ZHCNLocaleString @"zh_CN"

static NSLocale *__currentDateLocale = nil;
static NSLocale* currentDateLocale() {
    if (__currentDateLocale == nil) {
        __currentDateLocale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"CurrentDateLocale", nil)];
    }
    return __currentDateLocale;
}

#pragma mark - Getting begin of NSDate

//// Getting the beginning of the day
//static NSDate* beginningOfToday() {
//    NSDate *beginningOfToday = nil;
//    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginningOfToday interval:NULL forDate:[NSDate date]];
//    if (ok) {
//        return beginningOfToday;
//    }
//    else {
//        return nil;
//    }
//}

//// Getting the beginning of the day
//static NSDate *beginningOfTomorrow() {
//    NSDate *beginningOfTomorrow = nil;
//    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginningOfTomorrow interval:NULL forDate:[NSDate currentTimeTomorrow]];
//    if (ok) {
//        return beginningOfTomorrow;
//    }
//    else {
//        return nil;
//    }
//}

#pragma mark - date formmater

// yyyy-MM-dd HH:mm
static NSDateFormatter *__yearToMiniteFormatter = nil;
static NSDateFormatter *YearToMiniteFormatter() {
    if (__yearToMiniteFormatter == nil) {
        __yearToMiniteFormatter = [[NSDateFormatter alloc] init];
        [__yearToMiniteFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [__yearToMiniteFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return __yearToMiniteFormatter;
}

// yyyy-MM-dd EEEE
static NSDateFormatter *__yearToDayWeekFormatter = nil;
static NSDateFormatter *YearToDayWeekFormatter() {
    if (__yearToDayWeekFormatter == nil) {
        __yearToDayWeekFormatter = [[NSDateFormatter alloc] init];
        [__yearToDayWeekFormatter setLocale:currentDateLocale()];
        [__yearToDayWeekFormatter setDateFormat:@"yyyy-MM-dd EEEE"];
        [__yearToDayWeekFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return __yearToDayWeekFormatter;
}

// yyyy-MM-dd
static NSDateFormatter *__yearToDayFormatter = nil;
static NSDateFormatter *YearToDayFormatter() {
    if (__yearToDayFormatter == nil) {
        __yearToDayFormatter = [[NSDateFormatter alloc] init];
        [__yearToDayFormatter setLocale:currentDateLocale()];
        [__yearToDayFormatter setDateFormat:@"yyyy-MM-dd"];
        [__yearToDayFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return __yearToDayFormatter;
}

// MM.dd or MM月dd日
static NSDateFormatter *__monthToDayFormatter = nil;
static NSDateFormatter *MonthToDayFormatter() {
    if (__monthToDayFormatter == nil) {
        __monthToDayFormatter = [[NSDateFormatter alloc] init];
        [__monthToDayFormatter setDateFormat:NSLocalizedString(@"MonthToDayFormat", nil)];
        [__monthToDayFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return __monthToDayFormatter;
}

// MM.dd Mon or MM月dd日 周一
static NSDateFormatter *__monthToDayWFormatter = nil;
static NSDateFormatter *MonthToDayWFormatter() {
    if (__monthToDayWFormatter == nil) {
        __monthToDayWFormatter = [[NSDateFormatter alloc] init];
        [__monthToDayWFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"CurrentDateLocale", nil)]];
        [__monthToDayWFormatter setDateFormat:[NSString stringWithFormat:@"%@ E", NSLocalizedString(@"MonthToDayFormat", nil)]];
    }
    return __monthToDayWFormatter;
}

// HH:mm a
static NSDateFormatter *__hourToMiniteAFormatter = nil;
static NSDateFormatter *HourToMiniteAFormatter() {
    if (__hourToMiniteAFormatter == nil) {
        __hourToMiniteAFormatter = [[NSDateFormatter alloc] init];
        [__hourToMiniteAFormatter setDateFormat:@"HH:mm a"];
        [__hourToMiniteAFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return __hourToMiniteAFormatter;
}

// HH:mm
static NSDateFormatter *__hourToMiniteFormatter = nil;
static NSDateFormatter *HourToMiniteFormatter() {
    if (__hourToMiniteFormatter == nil) {
        __hourToMiniteFormatter = [[NSDateFormatter alloc] init];
        [__hourToMiniteFormatter setDateFormat:@"HH:mm"];
        [__hourToMiniteFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return __hourToMiniteFormatter;
}

#endif

