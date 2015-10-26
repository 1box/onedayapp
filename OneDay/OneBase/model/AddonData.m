//
//  AddonData.m
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AddonData.h"
#import "KMModelManager.h"
#import "AddonManager.h"
#import "DailyDoBase.h"


@implementation AddonData

@dynamic dailyDoName;
@dynamic orderIndex;
@dynamic display;
@dynamic title;
@dynamic icon;
@dynamic cartoon;
@dynamic numberOfCartoons;
@dynamic detectType;
@dynamic showChecked;
@dynamic tipImage;
@dynamic passwordOn;

@dynamic dailyDos;
@dynamic alarms;

+ (NSString *)entityName
{
    return @"AddonData";
}

+ (NSArray *)primaryKeys
{
    return @[@"dailyDoName"];
}

+ (NSDictionary *)keyMapping
{
    return @{
    @"dailyDoName" : @"daily_do_name",
    @"orderIndex" : @"order_index",
    @"display" : @"display",
    @"title" : @"title",
    @"icon" : @"icon",
    @"cartoon" : @"cartoon",
    @"numberOfCartoons" : @"number_of_cartoons",
    @"detectType" : @"detect_type",
    @"showChecked" : @"show_checked",
    @"tipImage" : @"tip_image",
    @"passwordOn" : @"password_on",
    };
}

+ (NSDictionary *)updateIgnoredKeys
{
    return @{[NSNumber numberWithInteger:NSIntegerMin] : @"orderIndex",
             @YES : @"display",
             @NO : @"passwordOn"};
}

+ (void)loadDefaultDataFromDefaultPlist
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultModels" ofType:@"plist"];
    if (path) {
        NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *addons = [rootDict objectForKey:@"AddonDataList"];
        
        for (NSDictionary *tmpDict in addons) {
            [self insertEntityWithDictionary:tmpDict syncrhonizeWithStore:YES];
        }
        
        [[KMModelManager sharedManager] saveContext:nil];
        [[AddonManager sharedManager] reorderAddons];
    }
}

- (BOOL)removeBlankDailyDos
{
    NSMutableArray *blankDailyDos = [NSMutableArray arrayWithCapacity:10];
    
    NSArray *dailyDos = [self.dailyDos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]]];
    [dailyDos enumerateObjectsUsingBlock:^(DailyDoBase *dailyDo, NSUInteger idx, BOOL *stop) {
        if ([dailyDo isBlankDailyDo]) {
            [blankDailyDos addObject:dailyDo];
        }
    }];
    
    if ([blankDailyDos count] > 0) {
        return [[KMModelManager sharedManager] removeEntities:[blankDailyDos copy] error:nil];
    }
    else {
        return YES;
    }
}

@end
