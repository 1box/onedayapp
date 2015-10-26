//
//  NSArray+NSArrayAdditions.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArrayAdditions)
- (BOOL)containStringCaseInsensitive:(NSString *)aString;

- (NSString *)stringWithEnum:(NSUInteger)enumVal;
- (NSUInteger)enumFromString:(NSString *)strVal default:(NSUInteger)def;
- (NSUInteger)enumFromString:(NSString *)strVal;
@end
