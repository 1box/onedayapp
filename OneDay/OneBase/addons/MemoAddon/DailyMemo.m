//
//  DailyMemo.m
//  OneDay
//
//  Created by Yu Tianhang on 13-1-18.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyMemo.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoManager.h"


@implementation DailyMemo

+ (NSString *)entityName
{
    return @"DailyMemoData";
}

#pragma mark - protected

- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)todayText
{
    // 3 memos
    int undoCount = 0;
    for (TodoData *todo in self.todos) {
        if (![todo.check boolValue]) {
            undoCount ++;
        }
    }
    return [NSString stringWithFormat:NSLocalizedString(@"MemoTodayText", nil), [self.todos count], undoCount];
}

- (NSString *)completionText
{
    NSString *ret = NSLocalizedString(@"MemoNoText", nil);
    if ([self.todos count] > 0) {
        
        if (![self.check boolValue]) {
            for (TodoData *todo in self.todos) {
                if (![todo.check boolValue]) {
                    ret = todo.content;
                    break;
                }
            }
        }
        else {
            ret = [NSString stringWithFormat:NSLocalizedString(@"MemoCompleteText", nil), [self.todos count]];
        }
    }
    return ret;
}
@end
