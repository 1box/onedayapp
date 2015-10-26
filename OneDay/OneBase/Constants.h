//
//  Constants.h
//  OneDay
//
//  Created by Yu Tianhang on 13-3-5.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#ifndef OneDay_Constants_h
#define OneDay_Constants_h

#import "NSUserDefaultsAdditions.h"

#define OneDayStoryboardName @"OneDayStoryboard"
#define UniversalStoryboardName @"UniversalStoryboard"

#define MainViewStoryboardID @"MainViewControllerID"
#define DailyDoViewStoryboardID @"DailyDoViewStoryboardID"

#define CurrentAddonsDidChangedNotification @"CurrentAddonsDidChangedNotification"

#define TrackMainViewEvent @"main_page"

#define kAutomaticLineNumberUserDefaultKey @"kAutomaticLineNumberUserDefaultKey"
static inline void setAutomaticLineNumber(BOOL automatic) {
    [[NSUserDefaults standardUserDefaults] setBool:automatic forKey:kAutomaticLineNumberUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL automaticLineNumber() {
    if ([NSUserDefaults firstTimeUseKey:kAutomaticLineNumberUserDefaultKey]) {
        // default YES
        setAutomaticLineNumber(YES);
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticLineNumberUserDefaultKey];
}

#define kHomeCoverSelectedIndexUserDefaultKey @"kHomeCoverSelectedIndexUserDefaultKey"
#define HomeCoverDidSelectedNotification @"HomeCoverDidSelectedNotification"

static inline void setHomeCoverSelectedIndex(NSInteger idx) {
    [[NSUserDefaults standardUserDefaults] setInteger:idx forKey:kHomeCoverSelectedIndexUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HomeCoverDidSelectedNotification object:nil];
}

static inline NSInteger homeCoverSelectedIndex() {
    if ([NSUserDefaults firstTimeUseKey:kHomeCoverSelectedIndexUserDefaultKey]) {
        // default 0
        setHomeCoverSelectedIndex(0);
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:kHomeCoverSelectedIndexUserDefaultKey];
}

#endif
