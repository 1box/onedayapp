//
//  AddonManager.m
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AddonManager.h"
#import "KMModelManager.h"
#import "AddonData.h"

#define kAddonsUserDefaultKey @"kAddonsUserDefaultKey"

/*
 * TODO:缓存addons，提高性能
 */

@interface AddonManager ()
@property (nonatomic, readwrite) NSInteger addonsCount;
@end

@implementation AddonManager

static AddonManager *_sharedManager;
+ (AddonManager *)sharedManager
{
    @synchronized(self) {
        if (_sharedManager == nil) {
            _sharedManager = [[AddonManager alloc] init];
        }
    }
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - getter

- (NSInteger)allAddonsCount
{
    NSError *error = nil;
    NSArray *result = [[KMModelManager sharedManager] entitiesWithQuery:nil
                                                      entityDescription:[AddonData entityDescription]
                                                                  error:&error];
    if (!error) {
        return [result count];
    }
    else {
        return 0;
    }
}

#pragma mark - public

- (NSArray *)currentAddons
{
    NSError *error = nil;
    NSArray *result = [[KMModelManager sharedManager] entitiesWithQuery:@{@"display" : @YES}
                                                      entityDescription:[AddonData entityDescription]
                                                             unFaulting:NO
                                                                 offset:0
                                                                  count:NSIntegerMax
                                                        sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderIndex" ascending:YES]]
                                                                  error:&error];
    if (!error) {
        self.addonsCount = [result count];
        return result;
    }
    else {
        self.addonsCount = 0;
        return nil;
    }
}

- (NSArray *)preparedAddons
{
    NSError *error = nil;
    NSArray *result = [[KMModelManager sharedManager] entitiesWithQuery:@{@"display" : @NO}
                                                      entityDescription:[AddonData entityDescription]
                                                             unFaulting:NO
                                                                 offset:0
                                                                  count:NSIntegerMax
                                                        sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderIndex" ascending:YES]]
                                                                  error:&error];
    if (!error) {
        return result;
    }
    else {
        return nil;
    }
}

- (NSArray *)hasTipAddons
{
    NSArray *addons = [self currentAddons];
    if (addons) {
        NSMutableArray *tipAddons = [NSMutableArray arrayWithCapacity:[addons count]];
        for (AddonData *tAddon in addons) {
            if (!KMEmptyString(tAddon.tipImage)) {
                [tipAddons addObject:tAddon];
            }
        }
        
        if ([tipAddons count] > 0) {
            return [tipAddons copy];
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (NSArray *)alarmAddons
{
    NSArray *addons = [self currentAddons];
    if (addons) {
        NSMutableArray *alarmAddons = [NSMutableArray arrayWithArray:addons];
        for (AddonData *tAddon in addons) {
            if ([tAddon.dailyDoName isEqualToString:@"DailyCash"] || [tAddon.dailyDoName isEqualToString:@"DailyShort"]) {
                [alarmAddons removeObject:tAddon];
            }
        }
        
        if ([alarmAddons count] > 0) {
            return [alarmAddons copy];
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (AddonData *)currentAddonForName:(NSString *)addonName
{
    NSArray *addons = [self currentAddons];
    
    __block AddonData *ret = nil;
    [addons enumerateObjectsUsingBlock:^(AddonData *addon, NSUInteger idx, BOOL *stop){
        if ([addon.dailyDoName isEqualToString:addonName]) {
            ret = addon;
        }
    }];
    
    return ret;
}

- (BOOL)moveAddon:(AddonData *)addon toIndex:(NSUInteger)index
{
    if (index == [addon.orderIndex intValue]) {
        return NO;
    }
    else {
        NSError *error = nil;
        
        if (index > [addon.orderIndex intValue]) {
            NSArray *greaterOrders = [[KMModelManager sharedManager] entitiesWithEqualQueries:@{@"display" : @YES}
                                                                              lessThanQueries:nil
                                                                       lessThanOrEqualQueries:@{@"orderIndex" : [NSNumber numberWithInteger:index]}
                                                                           greaterThanQueries:@{@"orderIndex" : addon.orderIndex}
                                                                    greaterThanOrEqualQueries:nil
                                                                              notEqualQueries:nil
                                                                            entityDescription:[AddonData entityDescription]
                                                                                   unFaulting:NO
                                                                                       offset:0
                                                                                        count:NSIntegerMax
                                                                              sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderIndex" ascending:YES]]
                                                                                        error:&error];
            
            if (!error) {
                for (AddonData *tmpAddon in greaterOrders) {
                    tmpAddon.orderIndex = [NSNumber numberWithInteger:[tmpAddon.orderIndex integerValue] - 1];
                }
            }
            else {
                return NO;
            }
        }
        else {
            NSArray *lessOrders = [[KMModelManager sharedManager] entitiesWithEqualQueries:@{@"display" : @YES}
                                                                           lessThanQueries:@{@"orderIndex" : addon.orderIndex}
                                                                    lessThanOrEqualQueries:nil
                                                                        greaterThanQueries:nil
                                                                 greaterThanOrEqualQueries:@{@"orderIndex" : [NSNumber numberWithInteger:index]}
                                                                           notEqualQueries:nil
                                                                         entityDescription:[AddonData entityDescription]
                                                                                unFaulting:NO
                                                                                    offset:0
                                                                                     count:NSIntegerMax
                                                                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderIndex" ascending:YES]]
                                                                                     error:&error];
            
            if (!error) {
                for (AddonData *tmpAddon in lessOrders) {
                    tmpAddon.orderIndex = [NSNumber numberWithInteger:[tmpAddon.orderIndex integerValue] + 1];
                }
            }
            else {
                return NO;
            }
        }
        
        addon.orderIndex = [NSNumber numberWithInteger:index];
        
        return [[KMModelManager sharedManager] saveContext:nil];
    }
}

- (BOOL)removeAddon:(AddonData *)addon
{
    NSError *error = nil;
    
    NSArray *greaterOrders = [[KMModelManager sharedManager] entitiesWithEqualQueries:@{@"display" : @YES}
                                                                      lessThanQueries:nil
                                                               lessThanOrEqualQueries:nil
                                                                   greaterThanQueries:@{@"orderIndex" : addon.orderIndex}
                                                            greaterThanOrEqualQueries:nil
                                                                      notEqualQueries:nil
                                                                    entityDescription:[AddonData entityDescription]
                                                                           unFaulting:NO
                                                                               offset:0
                                                                                count:NSIntegerMax
                                                                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderIndex" ascending:YES]]
                                                                                error:&error];
    
    if (!error) {
        for (AddonData *tmpAddon in greaterOrders) {
            tmpAddon.orderIndex = [NSNumber numberWithInteger:[tmpAddon.orderIndex integerValue] - 1];
        }
    }
    else {
        return NO;
    }
    
    addon.orderIndex = 0;
    addon.display = @NO;
    
    return [[KMModelManager sharedManager] saveContext:nil];
}

- (BOOL)addAddon:(AddonData *)addon
{
    addon.orderIndex = [NSNumber numberWithInt:[[self currentAddons] count]];
    addon.display = @YES;
    
    return [[KMModelManager sharedManager] saveContext:nil];
}

- (BOOL)reorderAddons
{
    NSArray *addons = [self currentAddons];
    if (addons) {
        for (int i=0; i < [addons count]; i++) {
            AddonData *tAddon = [addons objectAtIndex:i];
            tAddon.orderIndex = [NSNumber numberWithInt:i];
        }
        return [[KMModelManager sharedManager] saveContext:nil];
    }
    return YES;
}
@end
