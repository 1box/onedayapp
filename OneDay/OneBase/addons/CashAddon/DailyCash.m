//
//  DailyCash.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-28.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyCash.h"
#import "TodoData.h"
#import "SMDetector.h"
#import "KMDateUtils.h"

@implementation DailyCash

+ (NSString *)entityName
{
    return @"DailyCashData";
}

//+ (NSDictionary *)keyMapping
//{
//    NSMutableDictionary *keyMapping = [[[super keyMapping] mutableCopy] autorelease];
//    [keyMapping setObject:@"shortContent" forKey:@"short_content"];
//    
//    return keyMapping;
//}

#pragma mark - protected
- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)todayText
{
    CGFloat money = 0.f;
    for (TodoData *todo in self.todos) {
        NSNumber *todoCash = [[SMDetector defaultDetector] valueInString:todo.money byType:SmarkDetectTypeMoney];
        money += [todoCash floatValue];
    }
    
    if ([currentDateLocale().localeIdentifier isEqualToString:ENUSLocaleString]) {
        money *= RMBToDollarRate;
    }
    
    NSString *todayTextString = nil;
    if (money > 0) {
        todayTextString = [NSString stringWithFormat:NSLocalizedString(@"CashGainTodayText", nil), money];
    }
    else if (money == 0) {
        todayTextString = NSLocalizedString(@"CashEqualTodayText", nil);
    }
    else {
         todayTextString = [NSString stringWithFormat:NSLocalizedString(@"CashLoseTodayText", nil), -1*money];
    }
    
    return todayTextString;
}

- (NSString *)completionText
{
    NSString *completeTextString = NSLocalizedString(@"CashNoText", nil);
    
    if ([self.todos count] > 0) {
        
        CGFloat money = 0.f;
        for (TodoData *todo in self.todos) {
            NSNumber *todoCash = [[SMDetector defaultDetector] valueInString:todo.money byType:SmarkDetectTypeMoney];
            money += [todoCash floatValue];
        }
        
        if ([currentDateLocale().localeIdentifier isEqualToString:ENUSLocaleString]) {
            money *= RMBToDollarRate;
        }
        
        if (money > 0) {
            completeTextString = [NSString stringWithFormat:NSLocalizedString(@"CashGainCompleteText", nil), money];
        }
        else if (money == 0) {
            completeTextString = NSLocalizedString(@"CashEqualCompleteText", nil);
        }
        else {
            completeTextString = [NSString stringWithFormat:NSLocalizedString(@"CashLoseCompleteText", nil), -1*money];
        }
    }
    
    return completeTextString;
}
@end
