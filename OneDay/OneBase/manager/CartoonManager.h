//
//  MainCartoonManager.h
//  OneDay
//
//  Created by Yu Tianhang on 13-2-26.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ODCurrentCartoonIndexChangedNotification @"ODCurrentCartoonIndexChangedNotification"
#define kODCurrentCartoonIndexChangedNotificationIndexKey @"kODCurrentCartoonIndexChangedNotificationIndexKey"

#define ODCartoonManagerRunAllCartoonsNotification @"ODCartoonManagerRunAllCartoonsNotification"

#define kRandomCartoonSwitchUserDefaultKey @"kRandomCartoonSwitchUserDefaultKey"
static inline void setRandomCartoonSwitch(BOOL switchOn) {
    [[NSUserDefaults standardUserDefaults] setBool:switchOn forKey:kRandomCartoonSwitchUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL randomCartoonSwitch() {
    if ([NSUserDefaults firstTimeUseKey:kRandomCartoonSwitchUserDefaultKey]) {
        // default YES
        setRandomCartoonSwitch(YES);
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRandomCartoonSwitchUserDefaultKey];
}


@interface CartoonManager : NSObject

+ (CartoonManager *)sharedManager;
- (void)startChangeCartoonTimer;
- (void)stopChangeCartoonTimer;

@end
