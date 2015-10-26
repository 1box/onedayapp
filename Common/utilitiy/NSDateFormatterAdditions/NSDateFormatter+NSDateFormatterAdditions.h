//
//  NSDateFormatter+NSDateFormatterAdditions.h
//  OneDay
//
//  Created by Yu Tianhang on 13-1-28.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (NSDateFormatterAdditions)
- (NSString *)userFriendlyStringFromDate:(NSDate *)date;
- (NSDate *)todayDateFromString:(NSString *)aString;
@end
