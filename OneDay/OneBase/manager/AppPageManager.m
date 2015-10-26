//
//  AppPageManager.m
//  OneDay
//
//  Created by kimimaro on 13-10-10.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AppPageManager.h"
#import "AddonData.h"
#import "AddonManager.h"
#import "DailyDoViewController.h"

#define kAppPageHomepageUserDefaultKey @"kAppPageHomepageUserDefaultKey"

@implementation AppPageManager

static AppPageManager *_sharedManager = nil;
+ (AppPageManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[AppPageManager alloc] init];
    });
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt to alloc a second instance for a singleton.");
    return [super alloc];
}

#pragma mark - public

- (void)setAsHomepageAddon:(NSString *)addonName
{
    [[NSUserDefaults standardUserDefaults] setObject:addonName forKey:kAppPageHomepageUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)homepageAddon
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppPageHomepageUserDefaultKey];
}

- (BOOL)isHomepageAddon:(NSString *)addonName
{
    NSString *homepage = [self homepageAddon];
    return [addonName isEqualToString:homepage];
}

- (void)showHomepageForNavigation
{
    NSString *addonName = [[AppPageManager sharedManager] homepageAddon];
    if (!KMEmptyString(addonName)) {
        AddonData *tAddon = [[AddonManager sharedManager] currentAddonForName:addonName];
        if (tAddon) {
            UINavigationController *nav = [KMCommon rootNavigationController];
            DailyDoViewController *controller = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:DailyDoViewStoryboardID];
            controller.addon = tAddon;
            [nav pushViewController:controller animated:NO];
        }
    }
}

@end
