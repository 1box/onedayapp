//
//  NSDateFormatter+NSDateFormatterAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 13-1-28.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "NSDateFormatter+NSDateFormatterAdditions.h"
#import "NSDate+NSDateAdditions.h"

@implementation NSDateFormatter (NSDateFormatterAdditions)

- (NSString *)userFriendlyStringFromDate:(NSDate *)date
{
    NSString *ret = nil;
    if (date.isToday) {
        ret = NSLocalizedString(@"UserFriendlyDateStringToday", nil);
    }
    else {
        ret = [self stringFromDate:date];
    }
    return ret;
}

- (NSDate *)todayDateFromString:(NSString *)aString
{
    NSDate *tDate = [self dateFromString:aString];
    if (tDate.isToday) {
        return tDate;
    }
    else {
        return [tDate sameTimeToday];
    }
}
@end
