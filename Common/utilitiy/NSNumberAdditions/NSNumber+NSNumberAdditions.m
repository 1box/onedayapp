//
//  NSNumber+NSNumberAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSNumber+NSNumberAdditions.h"

@implementation NSNumber (NSNumberAdditions)

- (NSDate *)dateValue
{
    return [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
}
@end
