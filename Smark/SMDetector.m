//
//  SMDetector.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-16.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "SMDetector.h"
#import "KMDateUtils.h"

@implementation SMDetector

static SMDetector *_defaultDetector = nil;
+ (SMDetector*)defaultDetector
{
    @synchronized(self) {
        if (_defaultDetector == nil) {
            _defaultDetector = [[self alloc] init];
        }
        return _defaultDetector;
    }
}

#pragma mark - public

- (NSUInteger)lineNumberForString:(NSString *)aString
{
    NSError *error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:SMLineNumberRegEx options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    
    if (error) {
        return NSNotFound;
    }
    
    NSTextCheckingResult *firstMatch = [regEx firstMatchInString:aString options:0 range:NSMakeRange(0, [aString length])];
    NSRange matchRange = [firstMatch range];
    
    if (firstMatch) {
        NSString *matchString = [aString substringWithRange:matchRange];
        matchString = [matchString stringByTrimmingStrings:@[@" ", @"."]];
        return [matchString intValue];
    }
    else {
        return NSNotFound;
    }
}

- (NSArray *)itemInString:(NSString *)aString byType:(SmarkDetectType)type
{
    NSArray *ret = nil;
    if (!KMEmptyString(aString)) {
        if (type == SmarkDetectTypeDate) {
            ret = [self datesInString:aString];
        }
        else if (type == SmarkDetectTypeDuration) {
            ret = [self durationsInString:aString];
        }
        else {
            NSString *regExString = nil;
            NSRegularExpressionOptions options = NSRegularExpressionAllowCommentsAndWhitespace;
            options |= NSRegularExpressionAnchorsMatchLines;
            switch (type) {
                case SmarkDetectTypeMoney:
                    regExString = SMMoneyRegEx;
                    break;
                case SmarkDetectTypeCaloric:
                    options |= NSRegularExpressionCaseInsensitive;
                    regExString = SMCaloricRegEx;
                    break;
                case SmarkDetectTypeDistance:
                    options |= NSRegularExpressionCaseInsensitive;
                    regExString = SMDistanceRegEx;
                    break;
                case SmarkDetectTypeFrequency:
                    options |= NSRegularExpressionCaseInsensitive;
                    regExString = SMFrequencyRegEx;
                    break;
                case SmarkDetectTypeQuantity:
                    regExString = SMQuantityRegEx;
                    break;
                default:
                    break;
            }
            
            if (regExString) {
                ret = [self detectStringInString:aString forRegExString:regExString options:options];
            }
        }
    }
    return ret;
}

- (id)valueInString:(NSString *)aString byType:(SmarkDetectType)type
{
    id ret = nil;
    if (!KMEmptyString(aString)) {
        aString = [aString stringByReplacingOccurrencesOfString:SMChineseAuxWord withString:@""];
        switch (type) {
            case SmarkDetectTypeMoney:
            {
                NSString *unsignedString = [aString stringByTrimmingStrings:moneyUnitBeginSmark()];
                
                CGFloat money = [[unsignedString stringByTrimmingStrings:moneyUnits()] floatValue];
                NSString *unitString = [unsignedString stringByTrimmingStrings:numberSmark()];
                if ([dollarUnits() containStringCaseInsensitive:unitString]) {
                    money *= DollarToRMBRate;
                }
                
                NSString *signString = [[aString stringByTrimmingStrings:moneyUnits()] stringByTrimmingStrings:numberSmark()];
                if (KMEmptyString(signString) || [negativeMoneyUnitBeginSmark() containsObject:signString]) {
                    money *= -1;
                }
                
                return [NSNumber numberWithFloat:money];
            }
                break;
            case SmarkDetectTypeCaloric:
            {
                NSString *unsignedString = [aString stringByTrimmingStrings:caloricUnitBeginSmark()];
                
                CGFloat caloric = [[unsignedString stringByTrimmingStrings:caloricUnits()] floatValue];
                NSString *unitString = [unsignedString stringByTrimmingStrings:numberSmark()];
                if ([signleCalorieUnits() containStringCaseInsensitive:unitString] || [jouleUnits() containStringCaseInsensitive:unitString]) {
                    caloric /= 1000;
                }
                
                if ([kiloJouleUnits() containStringCaseInsensitive:unitString]) {
                    caloric *= 1/CalToJouleRate;
                }
                
                NSString *signString = [[aString stringByTrimmingStrings:caloricUnits()] stringByTrimmingStrings:numberSmark()];
                if ([negativeCaloricUnitBeginSmark() containsObject:signString]) {
                    caloric *= -1;
                }
                return [NSNumber numberWithFloat:caloric];
            }
                break;
                
            default:
                break;
        }
    }
    return ret;
}

#pragma mark - private

- (NSArray *)datesInString:(NSString *)aString
{
    NSError *error = nil;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllSystemTypes&NSTextCheckingTypeDate error:&error];
    
    if (error) {
        return nil;
    }
    
    NSMutableArray *mutRet = [NSMutableArray arrayWithCapacity:10];
    [detector enumerateMatchesInString:aString
                               options:0
                                 range:NSMakeRange(0, [aString length])
                            usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                                
                                NSString *matchString = [aString substringWithRange:match.range];
                                if ([matchString length] <= 5) {
                                    
                                    NSDate *tDate = [HourToMiniteFormatter() dateFromString:[matchString DBCString]];
                                    if (tDate) {
                                        [mutRet addObject:[tDate sameTimeToday]];
                                    }
                                }
                                else {
                                    [mutRet addObject:match.date];
                                }
                            }];
    return [mutRet copy];
}

- (NSArray *)durationsInString:(NSString *)aString
{
    NSError *error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:SMDurationRegEx options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    
    if (error) {
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    [regEx enumerateMatchesInString:aString
                            options:0
                              range:NSMakeRange(0, [aString length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
                             NSRange matchRange = [match range];
                             NSString *matchString = [aString substringWithRange:matchRange];
                             if (![durationFaultSmark() containsObject:matchString]) {
                                 [ret addObject:[self durationForString:matchString]];
                             }
                         }];
    return ret;
}

- (NSArray *)detectStringInString:(NSString *)aString forRegExString:(NSString *)regExString options:(NSRegularExpressionOptions)options
{
    NSError *error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:regExString options:options error:&error];
    
    if (error) {
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    [regEx enumerateMatchesInString:aString
                            options:0
                              range:NSMakeRange(0, [aString length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
                             NSRange matchRange = [match range];
                             NSString *matchString = [aString substringWithRange:matchRange];
                             [ret addObject:matchString];
    }];
    return ret;
}

- (NSNumber *)durationForString:(NSString *)aString
{
    NSNumber *ret = nil;
    
    if ([aString length] > 0) {
        aString = [aString stringByTrimmingStrings:durationBeginSmark()];
        aString = [aString stringByTrimmingStrings:durationEndSmark()];
    }
    
    NSRange hourUnitRange = NSMakeRange(NSNotFound, 0);
    for (NSString *hourUnit in durationHourUnit()) {
        if (hourUnitRange.location == NSNotFound) {
            hourUnitRange = [aString rangeOfString:hourUnit];
        }
    }
    
    if (hourUnitRange.length > 0) {
        NSString *hourString = [aString substringWithRange:NSMakeRange(0, hourUnitRange.location)];
        ret = [NSNumber numberWithInt:[hourString intValue]*3600];
    }
    
    NSRange minuteUnitRange = NSMakeRange(NSNotFound, 0);
    for (NSString *minuteUnit in durationMinuteUnit()) {
        if (minuteUnitRange.location == NSNotFound) {
            minuteUnitRange = [aString rangeOfString:minuteUnit];
        }
    }
    
    if (minuteUnitRange.location != NSNotFound) {
        if (hourUnitRange.length > 0) {
            NSString *minuteString = [aString substringWithRange:NSMakeRange(NSMaxRange(hourUnitRange),
                                                                             minuteUnitRange.location - NSMaxRange(hourUnitRange))];
            ret = [NSNumber numberWithInt:([ret intValue] + [minuteString intValue]*60)];
        }
        else {
            NSString *minuteString = [aString substringWithRange:NSMakeRange(0, minuteUnitRange.location)];
            ret = [NSNumber numberWithInt:[minuteString intValue]*60];
        }
    }
    return ret;
}
@end
