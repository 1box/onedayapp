//
//  AppDelegate.m
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AppDelegateBase.h"
#import "MainViewController.h"
#import "AddonData.h"
#import "TagManager.h"
#import "KMModelManager.h"
#import "AlarmManager.h"
#import "CartoonManager.h"
#import "AddonManager.h"
#import "PasswordManager.h"
#import "SplashHelper.h"
#import "iRate.h"
#import "iVersion.h"
#import "Constants.h"
#import "NSUserDefaultsAdditions.h"
#import "UINavigationController+HideKeyboard.h"


@interface AppDelegateBase () <iRateDelegate>
@end


@implementation AppDelegateBase

+ (void)initialize
{
    NSString *bundleID = [self bundleIDForRate];
    if (!KMEmptyString(bundleID)) {
        [iRate sharedInstance].applicationBundleID = bundleID;
        [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
        
//#warning debug code
//        [iRate sharedInstance].previewMode = YES;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([KMCommon isPadDevice]) {
//        split's viewControllers returns an array of views. The zero-index element should be the left view, the one-index element should be the right view.
        UISplitViewController *split = (UISplitViewController *)_window.rootViewController;
        self.nav = [split.viewControllers objectAtIndex:1];
    }
    else {
        self.nav = (UINavigationController *)_window.rootViewController;
    }
    
    MainViewController *mainView = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:MainViewStoryboardID];
    [_nav pushViewController:mainView animated:NO];
    
    [[KMTracker sharedTracker] setRootController:_nav];
    [[KMTracker sharedTracker] startTrack];
    
    [[KMModelManager sharedManager] start];
    if ([NSUserDefaults currentVersionFirstTimeRunByType:firstTimeTypeAppDelegate]
        || [[AddonManager sharedManager] allAddonsCount] == 0) {
        
        [AddonData loadDefaultDataFromDefaultPlist];
        [[TagManager sharedManager] loadDefaultTagsFromPlist];
    }
    
    [iRate sharedInstance].delegate = self;
    [[iVersion sharedInstance] checkForNewVersion];
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if ([[KMCommon OSVersion] floatValue] < 7.f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    }
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    [self handleLocalNotification:localNotification];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [self handleLocalNotification:notification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[AlarmManager sharedManager] rebuildAlarmNotifications];
    [[PasswordManager sharedManager] resetHasShownAddonDictionary];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self showLaunchLock];
}

#pragma mark - private

- (void)handleLocalNotification:(UILocalNotification *)notification
{
    if (notification) {
        [[SplashHelper sharedHelper] addFinishedBlock:^(SplashHelper *helper) {
            [[AlarmManager sharedManager] handleAlarmLocalNotification:notification];
        }];
    }
}

- (void)showLaunchLock
{
    if ([KMCommon isPadDevice]) {
        [[PasswordManager sharedManager] showLaunchLockIfNecessary];
    }
    else {
        [[SplashHelper sharedHelper] addFlipedBlock:^(SplashHelper *helper) {
            [[PasswordManager sharedManager] showLaunchLockIfNecessary];
        }];
    }
}

#pragma mark - extended

+ (NSString *)bundleIDForRate
{
    return @"";
}

#pragma mark - iRateDelegate

- (void)iRateUserDidAttemptToRateApp
{
    trackEvent(@"iRate", @"Confirm");
}

- (void)iRateUserDidDeclineToRateApp
{
    trackEvent(@"iRate", @"Decline");
}

@end
