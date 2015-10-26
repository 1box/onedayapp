//
//  AppPageManager.h
//  OneDay
//
//  Created by kimimaro on 13-10-10.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPageManager : NSObject

+ (AppPageManager *)sharedManager;

- (void)setAsHomepageAddon:(NSString *)addonName;
- (NSString *)homepageAddon;
- (BOOL)isHomepageAddon:(NSString *)addonName;

- (void)showHomepageForNavigation;

@end
