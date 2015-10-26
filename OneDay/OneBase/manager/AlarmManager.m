//
//  AlarmNotificationManager.m
//  MedAlarm
//
//  Created by Kimi on 12-10-15.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AlarmManager.h"
#import "AddonManager.h"
#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "AlarmData.h"
#import "TodoData.h"
#import "KMDateUtils.h"
#import "NSDateFormatter+NSDateFormatterAdditions.h"

#define kEverydayAlarmAlertKey 10909
#define kAddonAlarmAlertKey 10910


@interface AlarmManager () <UIAlertViewDelegate>
@property (nonatomic) UILocalNotification *localNotification;
@end


@implementation AlarmManager

static AlarmManager *_sharedManager = nil;
+ (AlarmManager *)sharedManager
{
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [[AlarmManager alloc] init];
        }
    }
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - alarms

- (NSArray *)alarmsForAddon:(AddonData *)addon
{
    return [addon.alarms sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"alarmTime" ascending:YES]]];
}

- (NSArray *)openAlarmsForAddon:(AddonData *)addon
{
    NSArray *alarms = [self alarmsForAddon:addon];
    
    NSMutableArray *mutRet = [NSMutableArray arrayWithCapacity:[alarms count]];
    [alarms enumerateObjectsUsingBlock:^(AlarmData *alarm, NSUInteger idx, BOOL *stop) {
        if ([alarm.open boolValue]) {
            [mutRet addObject:alarm];
        }
    }];
    return [mutRet copy];
}

- (AlarmData *)alarmForDictionary:(NSDictionary *)dictionary
{
    AlarmData *alarm = [AlarmData entityWithDictionary:dictionary];
    return alarm;
}

- (BOOL)insertOrUpdateAlarm:(AlarmData *)alarm toAddon:(AddonData *)addon
{
    BOOL success = [[KMModelManager sharedManager] insertOrUpdateEntity:&alarm error:nil];
    if (success) {
        alarm.addon = addon;
        
        if ([alarm needAlarmToday]) {
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:addon];
            TodoData *todo = [todayDo todoForAlarm:alarm];
            if (!todo) {
                todo = [todayDo insertNewTodoAtIndex:0];
            }
            [todo updateWithAlarm:alarm save:YES];  // save here
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AlarmInsertOrUpdateNotification object:self];
    }
    return success;
}

- (BOOL)removeAlarm:(AlarmData *)alarm
{
    DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:alarm.addon];
    TodoData *todo = [todayDo todoForAlarm:alarm];
    if (todo) {
        [[KMModelManager sharedManager] removeEntities:@[todo] save:NO error:nil];
    }
    
    BOOL success = [[KMModelManager sharedManager] removeEntities:@[alarm] error:nil];
    return success;
}

#pragma mark - alarm notifications

- (void)handleAlarmLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    AlarmNotificationType alarmType = [[notification.userInfo objectForKey:kAlarmNotificationTypeKey] integerValue];
    switch (alarmType) {
        case AlarmNotificationTypeAddonAlarm:
        {
            self.localNotification = notification;
            NSDate *createDate = [notification.userInfo objectForKey:kAlarmNotificationCreateDateKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[YearToDayFormatter() userFriendlyStringFromDate:createDate]
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Go and See", nil)
                                                  otherButtonTitles:nil];
            alert.tag = kAddonAlarmAlertKey;
            [alert show];
        }
            break;
        case AlarmNotificationTypeEveryday:
        {
            self.localNotification = notification;
            NSDate *createDate = [notification.userInfo objectForKey:kAlarmNotificationCreateDateKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[YearToDayFormatter() userFriendlyStringFromDate:createDate]
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Go and See", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Check All", nil), nil];
            alert.tag = kEverydayAlarmAlertKey;
            [alert show];
        }
            break;
            
        default:
            break;
    }
}

- (void)rebuildAlarmNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self scheduleAddonAlarmNotification];
    [self scheduleDailyAlarmNotification];
}

#pragma mark - private

- (void)scheduleAddonAlarmNotification
{
    NSMutableDictionary *mutLocalNotifications = [NSMutableDictionary dictionaryWithCapacity:20];
    
    NSArray *addons = [[AddonManager sharedManager] alarmAddons];
    [addons enumerateObjectsUsingBlock:^(AddonData *addon, NSUInteger idx, BOOL *stop) {
        
        NSArray *alarms = [[AlarmManager sharedManager] openAlarmsForAddon:addon];
        [alarms enumerateObjectsUsingBlock:^(AlarmData *alarm, NSUInteger idx, BOOL *stop) {
            
            for (NSDate *repeatTime in [alarm nextRepeatTimes]) {
                
                NSString *repeatTimeString = [HourToMiniteFormatter() stringFromDate:repeatTime];
                UILocalNotification *localNotification = [mutLocalNotifications objectForKey:repeatTimeString];
                if (!localNotification) {
                    localNotification = [[UILocalNotification alloc] init];
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.repeatInterval = 0;
                    localNotification.alertAction = NSLocalizedString(@"Go", nil);
                    localNotification.soundName = playAlarmSounds() ? UILocalNotificationDefaultSoundName : nil;
                    localNotification.fireDate = repeatTime;
                    localNotification.userInfo = @{
                                                   kAlarmNotificationTypeKey : [NSNumber numberWithInteger:AlarmNotificationTypeAddonAlarm],
                                                   kAlarmNotificationCreateDateKey : [NSDate date]
                                                   };
                }
                
                NSMutableString *message = [NSMutableString stringWithCapacity:100];
                NSString *alertBody = localNotification.alertBody;
                if (!KMEmptyString(alertBody)) {
                    [message appendFormat:@"%@; ", alertBody];
                }
                else {
                    [message appendFormat:@"%@: ", NSLocalizedString(addon.dailyDoName, nil)];
                }
                [message appendString:alarm.text];
                localNotification.alertBody = [message copy];
                
                [mutLocalNotifications setObject:localNotification forKey:repeatTimeString];
            }
        }];
    }];
    
    [mutLocalNotifications.allValues enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }];
}

- (void)scheduleDailyAlarmNotification
{
    if (alarmNotificationSwitch()) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.repeatInterval = 0;
        localNotification.alertAction = NSLocalizedString(@"Go", nil);
        localNotification.soundName = playAlarmSounds() ? UILocalNotificationDefaultSoundName : nil;
        NSDate *fireDate = [HourToMiniteFormatter() todayDateFromString:alarmNotificationFireTimeString()];
        if ([fireDate earlierDate:[NSDate date]] == fireDate) {
            fireDate = [fireDate dateByAddingDays:1];
        }
        localNotification.fireDate = fireDate;
        
        __block int badgeNumber = 0;
        __block NSMutableString *message = [NSMutableString string];
        
        NSArray *addons = [[AddonManager sharedManager] alarmAddons];
        [addons enumerateObjectsUsingBlock:^(AddonData *tAddon, NSUInteger idx, BOOL *stop) {
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:tAddon];
            
            if (![todayDo.check boolValue] && [todayDo.todos count] > 0) {
                
                int todoCount = 0;
                for (TodoData *todo in todayDo.todos) {
                    if (![todo.check boolValue]) {
                        todoCount ++;
                    }
                }
                
                if (badgeNumber != 0) {
                    [message appendFormat:@", "];
                }
                [message appendFormat:NSLocalizedString(@"_dailyAlarmNotificationMessage", nil), todoCount, NSLocalizedString(todayDo.addon.title, nil)];
                badgeNumber += todoCount;
            }
        }];
        
        localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"_dailyAlarmNotificationBody", nil), message];
        localNotification.applicationIconBadgeNumber = showAppIconBadge() ? badgeNumber : 0;
        
        localNotification.userInfo = @{
                                       kAlarmNotificationTypeKey : [NSNumber numberWithInteger:AlarmNotificationTypeEveryday],
                                       kAlarmNotificationCreateDateKey : [NSDate date]
                                       };
        
        if (badgeNumber > 0) {
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAddonAlarmAlertKey) {
        // do nothing
    }
    else {
        if (buttonIndex != alertView.cancelButtonIndex) {
            // mark all check
            NSArray *addons = [[AddonManager sharedManager] alarmAddons];
            [addons enumerateObjectsUsingBlock:^(AddonData *tAddon, NSUInteger idx, BOOL *stop) {
                DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:tAddon];
                if (![todayDo.check boolValue] && [todayDo.todos count] > 0) {
                    for (TodoData *todo in todayDo.todos) {
                        if (![todo.check boolValue]) {
                            todo.check = @YES;
                        }
                    }
                }
            }];
            [[KMModelManager sharedManager] saveContext:nil];
        }
    }
    
    [self rebuildAlarmNotifications];
}

@end
