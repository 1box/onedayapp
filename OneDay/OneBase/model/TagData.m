//
//  TagData.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TagData.h"
#import "DailyDoBase.h"
#import "KMModelManager.h"

@implementation TagData

@dynamic name;
@dynamic level;
@dynamic superTag;
@dynamic createTime;
@dynamic dailyDos;

+ (NSString *)entityName
{
    return @"TagData";
}

+ (NSArray *)primaryKeys
{
    return @[@"name"];
}

+ (NSDictionary *)keyMapping
{
    return @{
    @"name" : @"name",
    @"level" : @"level",
    @"superTag" : @"superTag",
    };
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    TagData *tag = [[[self class] alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext:insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
    tag.createTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    tag.level = @0;
    return tag;
}

@end

@implementation TagData (CoreDataGeneratedAccessors)

- (void)addDailyDosObject:(DailyDoBase *)value
{
    NSMutableArray *dailyDos = [self.dailyDos mutableCopy];
    if (![dailyDos containsObject:value]) {
        [dailyDos addObject:value];
    }
    self.dailyDos = [dailyDos copy];
}

- (void)removeDailyDosObject:(DailyDoBase *)value
{
    NSMutableArray *dailyDos = [self.dailyDos mutableCopy];
    if ([dailyDos containsObject:value]) {
        [dailyDos removeObject:value];
    }
    self.dailyDos = [dailyDos copy];
}

- (void)addDailyDos:(NSSet *)values
{
    
}

- (void)removeDailyDos:(NSSet *)values
{
    
}

@end
