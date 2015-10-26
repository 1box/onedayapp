//
//  NSDate+NSDateAdditions.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+CupertinoYankee.h"
#import "NSDate-Utilities.h"

@interface NSDate (NSDateAdditions)

+ (NSDate *)currentTimeTomorrow;
+ (NSDate *)currentTimeAfterDay:(NSInteger)days;

//- (BOOL)isToday;
//- (BOOL)isTomorrow;
- (BOOL)isSameDayWithDate:(NSDate *)date;

- (NSDate *)morning;
- (NSDate *)midnight;
- (NSDate *)sameTimeToday;
//- (NSDate *)sameTimeTomorrow;

@end
