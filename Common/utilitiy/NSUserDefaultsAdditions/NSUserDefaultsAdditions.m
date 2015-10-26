//
//  NSUserDefaultsAdditions.m
//  Base
//
//  Created by Tu Jianfeng on 6/14/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "NSUserDefaultsAdditions.h"

@implementation NSUserDefaults (SSCategory)

+ (BOOL)currentVersionFirstTimeRunByType:(firstTimeType)type
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    
    NSString *key = nil;
    switch (type) {
        case firstTimeTypeAppDelegate:
            key = @"__first_time_key_app_delegate__";
            break;
        case firstTimeTypeHomePage:
            key = @"__first_time_key_home_page__";
            break;
        default:
            break;
    }
    
    NSString *keyWithVersion = [NSString stringWithFormat:@"%@_%@", key, [KMCommon versionName]];
    NSInteger firstTime = [defaluts integerForKey:keyWithVersion];
    if (firstTime == 0) {
        [defaluts setInteger:1 forKey:keyWithVersion];
        [defaluts synchronize];
        
        return YES;
    }
    return NO;
}

+ (BOOL)currentVersionFirstTimeRunByKey:(NSString *)key
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSString *keyWithVersion = [NSString stringWithFormat:@"%@_%@", key, [KMCommon versionName]];
    NSInteger firstTime = [defaluts integerForKey:keyWithVersion];
    if (firstTime == 0) {
        [defaluts setInteger:1 forKey:keyWithVersion];
        [defaluts synchronize];
        
        return YES;
    }
    return NO;
}

+ (BOOL)firstTimeRunByType:(firstTimeType)type
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    
    NSString *key = nil;
    switch (type) {
        case firstTimeTypeAppDelegate:
            key = @"__first_time_key_app_delegate__";
            break;
        case firstTimeTypeHomePage:
            key = @"__first_time_key_home_page__";
            break;
        default:
            break;
    }
    
    NSInteger firstTime = [defaluts integerForKey:key];
    if (firstTime == 0) {
        [defaluts setInteger:1 forKey:key];
        [defaluts synchronize];
        
        return YES;
    }
    return NO;
}

+ (BOOL)firstTimeUseKey:(NSString *)aKey
{
    NSString *firstTimeUseKey = [NSString stringWithFormat:@"first_time_use_%@", aKey];
    
    BOOL ret = ![[NSUserDefaults standardUserDefaults] boolForKey:firstTimeUseKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:firstTimeUseKey];
    return ret;
}

@end
