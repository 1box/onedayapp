//
//  NSArray+NSArrayAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSArray+NSArrayAdditions.h"

@implementation NSArray (NSArrayAdditions)

- (BOOL)containStringCaseInsensitive:(NSString *)aString
{
    __block BOOL ret = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if ([obj isKindOfClass:[NSString class]]) {
            NSRange tRange = [obj rangeOfString:aString options:NSCaseInsensitiveSearch];
            ret |= (tRange.location != NSNotFound);
        }
    }];
    return ret;
}

- (NSString*)stringWithEnum:(NSUInteger)enumVal
{
    return [self objectAtIndex:enumVal];
}

- (NSUInteger)enumFromString:(NSString *)strVal default:(NSUInteger)def
{
    NSUInteger n = [self indexOfObject:strVal];
    if(n == NSNotFound) n = def;
    return n;
}

- (NSUInteger)enumFromString:(NSString *)strVal
{
    return [self enumFromString:strVal default:0];
}
@end
