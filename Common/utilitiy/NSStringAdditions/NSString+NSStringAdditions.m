//
//  NSString+NSStringAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-12.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSString+NSStringAdditions.h"

@implementation NSString (NSStringAdditions)

- (BOOL)isInputComponent
{
    return [self length] == 1 && isalpha([self characterAtIndex:0]);
}

- (NSString *)stringByTrimmingStrings:(NSArray *)strings
{
//    NSMutableString *tmpSetString = [NSMutableString string];
//    for (NSString *tmpString in strings) {
//        if ([tmpSetString rangeOfString:tmpString].location == NSNotFound) {
//            [tmpSetString appendString:tmpString];
//        }
//    }
//    return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:tmpSetString]];
    
    NSMutableString *tMutableString = [self mutableCopy];
    for (NSString *tString in strings) {
        [tMutableString replaceOccurrencesOfString:tString withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tMutableString length])];
        
    }
    return [tMutableString copy];
}

- (NSString *)SBCString
{
    return [self stringByReplacingOccurrencesOfString:@":" withString:@"："];
}

- (NSString *)DBCString
{
    return [self stringByReplacingOccurrencesOfString:@"：" withString:@":"];
}

@end
