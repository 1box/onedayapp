//
//  PasswordManager.m
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "PasswordManager.h"
#import "DotLockViewController.h"
#import "AddonManager.h"
#import "KMModelManager.h"
#import "AddonData.h"

#define kLaunchPasswordOpenUserDefaultKey @"kLaunchPasswordOpenUserDefaultKey"

#define kDotLockPasswordUserDefaultKey @"kDotLockPasswordUserDefaultKey"
#define kDotLockPasswordOpenUserDefaultKey @"kDotLockPasswordOpenUserDefaultKey"


@interface PasswordManager () <LockViewControllerDelegate> {
    BOOL _lockViewHasShown;
}
@property (nonatomic) NSMutableDictionary *mutAddonLockDictionary;
@end

@implementation PasswordManager

static PasswordManager *_sharedManager = nil;
+ (PasswordManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setHasShownLockForAddon:(AddonData *)addon
{
    if (!_mutAddonLockDictionary) {
        self.mutAddonLockDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    [_mutAddonLockDictionary setObject:@YES forKey:addon.dailyDoName];
}

- (BOOL)hasShownLockForAddon:(AddonData *)addon
{
    BOOL ret = NO;
    if (_mutAddonLockDictionary) {
        ret = [[_mutAddonLockDictionary objectForKey:addon.dailyDoName] boolValue];
    }
    return ret;
}

- (void)resetHasShownAddonDictionary
{
    self.mutAddonLockDictionary = nil;
}

- (void)showLaunchLockIfNecessary
{
    if ([PasswordManager launchPasswordOpen]) {
        InfoStatus status = InfoStatusFirstTimeSetting;
        if ([PasswordManager hasDotLockPassword]) {
            status = InfoStatusNormal;
        }
        [self showLockViewWithInfoStatus:status pageType:LockViewPageTypeLaunch addon:nil finishBlock:nil];
    }
}

- (void)showAddonLock:(AddonData *)addon finishBlock:(LockViewDismissBlock)finishedBlock
{
    if ([addon.passwordOn boolValue] && ![self hasShownLockForAddon:addon]) {
        InfoStatus status = InfoStatusFirstTimeSetting;
        if ([PasswordManager hasDotLockPassword]) {
            status = InfoStatusNormal;
        }
        [self showLockViewWithInfoStatus:status pageType:LockViewPageTypeAddon addon:addon finishBlock:finishedBlock];
        
        [self setHasShownLockForAddon:addon];
    }
}

- (void)showResetLock
{
    if ([PasswordManager hasDotLockPassword]) {
        [self showLockViewWithInfoStatus:InfoStatusNormal
                                pageType:LockViewPageTypeReset
                                   addon:nil
                             finishBlock:^(DotLockViewController *controller) {
                                 
                                 [self resetHasShownAddonDictionary];
                                 [PasswordManager setDotLockPassword:nil];
                                 
                                 [self showLockViewWithInfoStatus:InfoStatusFirstTimeSetting
                                                         pageType:LockViewPageTypeReset
                                                            addon:nil
                                                      finishBlock:nil];
                             }];
    }
    else {
        [self resetHasShownAddonDictionary];
        [PasswordManager setDotLockPassword:nil];
                                 
        [self showLockViewWithInfoStatus:InfoStatusFirstTimeSetting
                                pageType:LockViewPageTypeReset
                                   addon:nil
                             finishBlock:nil];
    }
}

- (void)showLockViewWithInfoStatus:(InfoStatus)status pageType:(LockViewPageType)pageType addon:(AddonData *)addon finishBlock:(LockViewDismissBlock)aBlock
{
    if (!_lockViewHasShown) {
        DotLockViewController *controller = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:DotLockStoryBoardID];
        controller.delegate = self;
        controller.infoLabelStatus = status;
        controller.pageType = pageType;
        controller.addon = addon;
        controller.finishBlock = aBlock;
        
//        if ([KMCommon isPadDevice]) {
//            controller.modalPresentationStyle = UIModalPresentationFormSheet;
//        }
        
        UIViewController *topMost = [KMCommon topMostViewControllerFor:nil];
        [topMost presentViewController:controller animated:YES completion:nil];
        
        _lockViewHasShown = YES;
    }
}

#pragma mark - launch lock

+ (BOOL)launchPasswordOpen
{
    if ([NSUserDefaults firstTimeUseKey:kLaunchPasswordOpenUserDefaultKey]) {
        [self setLaunchPasswordOpen:YES];
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLaunchPasswordOpenUserDefaultKey];
}

+ (void)setLaunchPasswordOpen:(BOOL)open
{
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:kLaunchPasswordOpenUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - reset lock

+ (BOOL)passwordOpen
{
    BOOL ret = [self launchPasswordOpen];
    NSArray *currentAddons = [[AddonManager sharedManager] currentAddons];
    for (AddonData *addon in currentAddons) {
        ret |= [addon.passwordOn boolValue];
    }
    return ret;
}

+ (void)setPasswordOpen:(BOOL)open
{
    [self setLaunchPasswordOpen:open];
    NSArray *currentAddons = [[AddonManager sharedManager] currentAddons];
    for (AddonData *addon in currentAddons) {
        addon.passwordOn = [NSNumber numberWithBool:open];
    }
    [[KMModelManager sharedManager] saveContext:nil];
}

#pragma mark - dot lock

+ (BOOL)hasDotLockPassword
{
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kDotLockPasswordUserDefaultKey];
    return !KMEmptyString(password);
}

+ (BOOL)checkDotLockPassword:(NSString *)password
{
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kDotLockPasswordUserDefaultKey];
    if (password && savedPassword && [password isEqualToString:savedPassword]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)setDotLockPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:kDotLockPasswordUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - LockViewControllerDelegate

- (void)lockViewControllerHasDismiss:(DotLockViewController *)controller
{
    _lockViewHasShown = NO;
}

@end
