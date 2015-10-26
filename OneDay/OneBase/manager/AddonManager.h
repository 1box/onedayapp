//
//  AddonManager.h
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddonData;

@interface AddonManager : NSObject

@property (nonatomic, readonly) NSInteger addonsCount;
@property (nonatomic, readonly) NSInteger allAddonsCount;

+ (AddonManager *)sharedManager;

- (NSArray *)currentAddons;
- (NSArray *)preparedAddons;
- (NSArray *)hasTipAddons;
- (NSArray *)alarmAddons;
- (AddonData *)currentAddonForName:(NSString *)addonName;

// return YES when succeced
- (BOOL)moveAddon:(AddonData *)addon toIndex:(NSUInteger)index;
- (BOOL)removeAddon:(AddonData *)addon;
- (BOOL)addAddon:(AddonData *)addon;
- (BOOL)reorderAddons;
@end
