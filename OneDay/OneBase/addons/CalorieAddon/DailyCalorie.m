//
//  DailyCalorie.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-8.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyCalorie.h"
#import "TodoData.h"
#import "SMDetector.h"

@implementation DailyCalorie

+ (NSString *)entityName
{
    return @"DailyCalorieData";
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
    CGFloat calorie = 0.f;
    for (TodoData *todo in self.todos) {
        NSNumber *todoCalorie = [[SMDetector defaultDetector] valueInString:todo.caloric byType:SmarkDetectTypeCaloric];
        calorie += [todoCalorie floatValue];
    }
    
    NSString *todayTextString = nil;
    if (calorie > 0) {
        todayTextString = [NSString stringWithFormat:NSLocalizedString(@"CalorieGainTodayText", nil), calorie];
    }
    else if (calorie == 0) {
        todayTextString = NSLocalizedString(@"CalorieEqualTodayText", nil);
    }
    else {
        todayTextString = [NSString stringWithFormat:NSLocalizedString(@"CalorieLoseTodayText", nil), -1*calorie];
    }
    
    return todayTextString;
}

- (NSString *)completionText
{
    NSString *completeTextString = NSLocalizedString(@"CalorieNoText", nil);
    if ([self.todos count] > 0) {
        CGFloat calorie = 0.f;
        for (TodoData *todo in self.todos) {
            NSNumber *todoCalorie = [[SMDetector defaultDetector] valueInString:todo.caloric byType:SmarkDetectTypeCaloric];
            calorie += [todoCalorie floatValue];
        }
        
        if (calorie > 0) {
            completeTextString = [NSString stringWithFormat:NSLocalizedString(@"CalorieGainCompleteText", nil), calorie];
        }
        else if (calorie == 0) {
            completeTextString = NSLocalizedString(@"CalorieEqualCompleteText", nil);
        }
        else {
            completeTextString = [NSString stringWithFormat:NSLocalizedString(@"CalorieLoseCompleteText", nil), -1*calorie];
        }
    }
    return completeTextString;
}
@end
