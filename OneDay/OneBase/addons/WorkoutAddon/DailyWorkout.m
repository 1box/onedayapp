//
//  DailyWorkout.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-28.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyWorkout.h"
#import "TodoData.h"

@implementation DailyWorkout

+ (NSString *)entityName
{
    return @"DailyWorkoutData";
}

//+ (NSDictionary *)keyMapping
//{
//    NSMutableDictionary *keyMapping = [[[super keyMapping] mutableCopy] autorelease];
//    [keyMapping setObject:@"shortContent" forKey:@"short_content"];
//    
//    return keyMapping;
//}
//

#pragma mark - protected
- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)completionText
{
    NSString *completeString = NSLocalizedString(@"WorkoutNoText", nil);
    if ([self.todos count] > 0) {
        
        int checkedTodoCount = 0;
        for (TodoData *todo in self.todos) {
            if ([todo.check boolValue]) {
                checkedTodoCount ++;
            }
        }
        NSString *tString = [NSString stringWithFormat:NSLocalizedString(@"WorkoutCompleteText", nil), ([self.todos count] == 0 ? 0.0 : ((float)checkedTodoCount/[self.todos count])*100)];
        completeString = [NSString stringWithFormat:@"%@%@", tString, @"%"];
    }
    
    return completeString;
}
@end
