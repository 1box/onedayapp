//
//  NSString+SMString.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-18.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSString+SMString.h"
#import "SMConstants.h"

@implementation NSString (SMString)

- (NSString *)stringByTrimmingLineNumber
{
    NSError *error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:SMLineNumberRegEx options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    
    if (error) {
        return nil;
    }
    
    NSTextCheckingResult *firstMatch = [regEx firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    NSRange matchRange = [firstMatch range];
    
    if (firstMatch) {
        NSString *matchString = [self substringWithRange:matchRange];
        matchString = [self stringByReplacingOccurrencesOfString:matchString withString:@"" options:0 range:NSMakeRange(0, [matchString length])];
        matchString = [matchString substringFromIndex:1];
        return matchString;
    }
    else {
        return self;
    }
}
@end
