//
//  DailyScheduleAddon.m
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailySchedule.h"
#import "TodoData.h"

@implementation DailySchedule

@dynamic notes;

+ (NSString *)entityName
{
    return @"DailyScheduleData";
}

+ (NSDictionary *)keyMapping
{
    NSMutableDictionary *keyMapping = [[super keyMapping] mutableCopy];
    [keyMapping setObject:@"notes" forKey:@"notes"];
    
    return keyMapping;
}

#pragma mark - protected
- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)completionText
{
    NSString *completeString = NSLocalizedString(@"ScheduleNoText", nil);
    
    if ([self.todos count] > 0) {
        
        int checkedTodoCount = 0;
        for (TodoData *todo in self.todos) {
            if ([todo.check boolValue]) {
                checkedTodoCount ++;
            }
        }
        NSString *tString = [NSString stringWithFormat:NSLocalizedString(@"ScheduleCompleteText", nil), ([self.todos count] == 0 ? 0.0 : ((float)checkedTodoCount/[self.todos count])*100)];
        completeString = [NSString stringWithFormat:@"%@%@", tString, @"%"];
    }
    return completeString;
}
@end
