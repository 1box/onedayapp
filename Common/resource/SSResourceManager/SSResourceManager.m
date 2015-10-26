//
//  SSResourceManager.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SSResourceManager.h"

//file type
//plist priority higher than strings
#define strings @"strings"
#define plist @"plist"

//UI setting
//lowest priority
#define CommonUISetting @"CommonUISetting"
//middle priority
#define ProjectUISetting @"ProjectUISetting"
//high  priority
#define IPhoneUISetting @"IPhoneUISetting"
#define IPadUISetting @"IPadUISetting"

//Logic setting
//lowest priority
#define CommonLogicSetting @"CommonLogicSetting"
//middle priority
#define ProjectLogicSetting @"ProjectLogicSetting"
//high priority
#define IPhoneLogicSetting @"IPhoneLogicSetting"
#define IPadLogicSetting @"IPadLogicSetting"

// theme mode
#define IPhoneDayModeThemeUISetting @"IPhoneDayModeThemeUISetting"
#define IPhoneNightModeThemeUISetting @"IPhoneNightModeThemeUISetting"
#define IPadDayModeThemeUISetting @"IPadDayModeThemeUISetting"
#define IPadNightModeThemeUISetting @"IPadNightModeThemeUISetting"


@interface SSResourceManager()
@property (nonatomic) NSMutableDictionary * UISettingDict;
@property (nonatomic) NSMutableDictionary * logicSettingDict;
@end


@implementation SSResourceManager

static SSResourceManager *shareBundle = nil;
+ (SSResourceManager *)shareBundle
{
    @synchronized(self) {
        if (shareBundle == nil) {
            shareBundle = [[SSResourceManager alloc] init];
        }
    }
    return shareBundle;
}

#pragma mark - public

- (void)switchToThemeMode:(SSThemeMode)themeMode
{
    NSDictionary *userDefinedUIDict = nil;
    NSDictionary *userDefinedUIPlistDict = nil;
    
    switch (themeMode) {
        case SSThemeModeNight:
        {
            if ([KMCommon isPadDevice]) {
                userDefinedUIDict = [self dictionaryWithFilePathForResource:IPadNightModeThemeUISetting ofType:strings];
                if (userDefinedUIDict == nil) {
                    userDefinedUIDict = [self dictionaryWithFilePathForResource:IPadDayModeThemeUISetting ofType:strings];
                }
                
                userDefinedUIPlistDict = [self dictionaryWithFilePathForResource:IPadNightModeThemeUISetting ofType:plist];
                if (userDefinedUIPlistDict == nil) {
                    userDefinedUIPlistDict = [self dictionaryWithFilePathForResource:IPadDayModeThemeUISetting ofType:plist];
                }
            }
            else {
                userDefinedUIDict = [self dictionaryWithFilePathForResource:IPhoneNightModeThemeUISetting ofType:strings];
                if (userDefinedUIDict == nil) {
                    userDefinedUIDict = [self dictionaryWithFilePathForResource:IPhoneDayModeThemeUISetting ofType:strings];
                }
                
                userDefinedUIPlistDict = [self dictionaryWithFilePathForResource:IPhoneNightModeThemeUISetting ofType:plist];
                if (userDefinedUIPlistDict == nil) {
                    userDefinedUIPlistDict = [self dictionaryWithFilePathForResource:IPhoneDayModeThemeUISetting ofType:plist];
                }
            }
        }
            break;
        case SSThemeModeDay:
        {
            if ([KMCommon isPadDevice]) {
                userDefinedUIDict = [self dictionaryWithFilePathForResource:IPadDayModeThemeUISetting ofType:strings];
                userDefinedUIPlistDict = [self dictionaryWithFilePathForResource:IPadDayModeThemeUISetting ofType:plist];
            }
            else {
                userDefinedUIDict = [self dictionaryWithFilePathForResource:IPhoneDayModeThemeUISetting ofType:strings];
                userDefinedUIPlistDict = [self dictionaryWithFilePathForResource:IPhoneDayModeThemeUISetting ofType:plist];
            }
        }
            break;
        default:
            break;
    }
    
    [self initialUIDictionary];
    
    if (!_UISettingDict) {
        self.UISettingDict = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    
    [self addDictionaryToUISettingDict:userDefinedUIDict];
    [self addDictionaryToUISettingDict:userDefinedUIPlistDict];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSResourceManagerThemeModeChangedNotification object:self];
}

#pragma mark -- init
- (id)init
{
    self = [super init];
    if (self) {
        [self initialLogicDictionary];
        [self initialUIDictionary];
    }
    return self;
}

- (void)initialLogicDictionary
{
    NSDictionary * commonLogicDict = [self dictionaryWithFilePathForResource:CommonLogicSetting ofType:strings];
    NSDictionary * projectLogicDict = [self dictionaryWithFilePathForResource:ProjectLogicSetting ofType:strings];
    NSDictionary * deviceLogicDict = nil;
    if ([KMCommon isPadDevice]) {
        deviceLogicDict = [self dictionaryWithFilePathForResource:IPadLogicSetting ofType:strings];
        if (deviceLogicDict == nil) {
            deviceLogicDict = [self dictionaryWithFilePathForResource:IPhoneLogicSetting ofType:strings];
        }
    }
    else {
        deviceLogicDict = [self dictionaryWithFilePathForResource:IPhoneLogicSetting ofType:strings];
    }
    
    NSDictionary * commonLogicPListDict = [self dictionaryWithFilePathForResource:CommonLogicSetting ofType:plist];
    NSDictionary * projectLogicPListDict = [self dictionaryWithFilePathForResource:ProjectLogicSetting ofType:plist];
    NSDictionary * deviceLogicPListDict = nil;
    if ([KMCommon isPadDevice]) {
        deviceLogicPListDict = [self dictionaryWithFilePathForResource:IPadLogicSetting ofType:plist];
        if (deviceLogicPListDict == nil) {
            deviceLogicPListDict = [self dictionaryWithFilePathForResource:IPhoneLogicSetting ofType:plist];
        }
    }
    else {
        deviceLogicPListDict = [self dictionaryWithFilePathForResource:IPhoneLogicSetting ofType:plist];
    }
    
    self.logicSettingDict = [[NSMutableDictionary alloc] initWithCapacity:100];
    
    [self addDictionaryToLogicSettingDict:commonLogicDict];
    [self addDictionaryToLogicSettingDict:commonLogicPListDict];
    
    [self addDictionaryToLogicSettingDict:projectLogicDict];
    [self addDictionaryToLogicSettingDict:projectLogicPListDict];
    
    [self addDictionaryToLogicSettingDict:deviceLogicDict];
    [self addDictionaryToLogicSettingDict:deviceLogicPListDict];
}

- (void)initialUIDictionary
{
    NSDictionary * commonUIDict = [self dictionaryWithFilePathForResource:CommonUISetting ofType:strings];
    NSDictionary * projectUIDict = [self dictionaryWithFilePathForResource:ProjectUISetting ofType:strings];
    NSDictionary * deviceUIDict = nil;
    if ([KMCommon isPadDevice]) {
        deviceUIDict = [self dictionaryWithFilePathForResource:IPadUISetting ofType:strings];
        if (deviceUIDict == nil) {
            deviceUIDict = [self dictionaryWithFilePathForResource:IPhoneUISetting ofType:strings];
        }
    }
    else {
        deviceUIDict = [self dictionaryWithFilePathForResource:IPhoneUISetting ofType:strings];
    }
    
    NSDictionary * commonUIPListDict = [self dictionaryWithFilePathForResource:CommonUISetting ofType:plist];
    NSDictionary * projectUIPListDict = [self dictionaryWithFilePathForResource:ProjectUISetting ofType:plist];
    NSDictionary * deviceUIPListDict = nil;
    if ([KMCommon isPadDevice]) {
        deviceUIPListDict = [self dictionaryWithFilePathForResource:IPadUISetting ofType:plist];
        if (deviceUIPListDict == nil) {
            deviceUIPListDict = [self dictionaryWithFilePathForResource:IPhoneUISetting ofType:plist];
        }
    }
    else {
        deviceUIPListDict = [self dictionaryWithFilePathForResource:IPhoneUISetting ofType:plist];
    }
    
    self.UISettingDict = [[NSMutableDictionary alloc] initWithCapacity:100];
    
    [self addDictionaryToUISettingDict:commonUIDict];
    [self addDictionaryToUISettingDict:commonUIPListDict];
    
    [self addDictionaryToUISettingDict:projectUIDict];
    [self addDictionaryToUISettingDict:projectUIPListDict];

    [self addDictionaryToUISettingDict:deviceUIDict];
    [self addDictionaryToUISettingDict:deviceUIPListDict];
}

#pragma mark -- utils

- (NSDictionary *)dictionaryWithFilePathForResource:(NSString *)name ofType:(NSString *)ext
{
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSDictionary * dict = nil;
    if (path != nil) {
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return dict;
}

- (void)addDictionaryToUISettingDict:(NSDictionary *)dict
{
    [_UISettingDict addEntriesFromDictionary:dict];
}

- (void)addDictionaryToLogicSettingDict:(NSDictionary *)dict
{
    [_logicSettingDict addEntriesFromDictionary:dict];
}

- (id)dictionary:(NSDictionary *)dict forKey:(NSString *)key defaultValue:(id)defaultValue
{
    id result = [dict objectForKey:key];
    if (result == nil) {
        result = defaultValue;
    }
    return result;
}

- (id)dictionary:(NSDictionary *)dict forKey:(NSString *)key
{
    id result =  [dict objectForKey:key];
    if (result == nil) {
        SSLog(@"no key named %@", key);
    }
    return result;
}

#pragma mark -- public for logic setting

- (NSString *)logicStringForKey:(NSString *)key defaultValue:(NSString *)dValue
{
    return [self dictionary:_logicSettingDict forKey:key defaultValue:dValue];
}

- (NSDictionary *)logicDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)dDict
{
    return [self dictionary:_logicSettingDict forKey:key defaultValue:dDict];
}

- (NSArray *)logicArrayForKey:(NSString *)key defaultValue:(NSArray *)dArray
{
    return [self dictionary:_logicSettingDict forKey:key defaultValue:dArray];
}

- (float)logicFloatForKey:(NSString *)key defaultValue:(float)dValue
{
    return  [[self dictionary:_UISettingDict forKey:key defaultValue:[NSNumber numberWithFloat:dValue]] floatValue];
}

- (int)logicIntForKey:(NSString *)key defaultValue:(int)dValue
{
    return [[self dictionary:_logicSettingDict forKey:key defaultValue:[NSNumber numberWithFloat:dValue]] intValue];
}
- (BOOL)logicBoolForKey:(NSString *)key defaultValue:(BOOL)dValue
{
    NSNumber * number = [NSNumber numberWithInt:dValue ? 1 : 0];
    return [[self dictionary:_logicSettingDict forKey:key defaultValue:number] boolValue];
}

//no default

- (NSString *)logicStringForKey:(NSString *)key
{
    return [self dictionary:_logicSettingDict forKey:key];
}
- (float)logicFloatForKey:(NSString *)key
{
    id result = [self dictionary:_logicSettingDict forKey:key];
    if (result == nil) {
        return 0.f;
    }
    return [result floatValue];
}
- (int)logicIntForKey:(NSString *)key
{
    id result = [self dictionary:_logicSettingDict forKey:key];
    if (result == nil) {
        return 0;
    }
    return [result intValue];
}

- (NSDictionary *)logicDictionaryForKey:(NSString *)key
{
    return [self dictionary:_logicSettingDict forKey:key];
}

- (NSArray *)logicArrayForKey:(NSString *)key
{
    return [self dictionary:_logicSettingDict forKey:key];
}

- (BOOL)logicBoolForKey:(NSString *)key
{
    id result = [self dictionary:_logicSettingDict forKey:key];
    if (result == nil) {
        return NO;
    }
    return [result boolValue];

}

#pragma mark -- public for UI setting

- (NSString *)UIStringForKey:(NSString *)key defaultValue:(NSString *)dValue
{
    return [self dictionary:_UISettingDict forKey:key defaultValue:dValue];
}

- (float)UIFloatForKey:(NSString *)key defaultValue:(float)dValue
{
    id result = [self dictionary:_UISettingDict forKey:key defaultValue:[NSNumber numberWithFloat:dValue]];
    return [result floatValue];
}

- (int)UIIntForKey:(NSString *)key defaultValue:(int)dValue
{
    id result = [self dictionary:_UISettingDict forKey:key defaultValue:[NSNumber numberWithFloat:dValue]];
    return [result floatValue];
}

- (NSDictionary *)UIDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)dDict
{
    return [self dictionary:_UISettingDict forKey:key defaultValue:dDict];
}

- (NSArray *)UIArrayForKey:(NSString *)key defaultValue:(NSArray *)dArray
{
    return [self dictionary:_UISettingDict forKey:key defaultValue:dArray];
}

- (BOOL)UIBoolForKey:(NSString *)key defaultValue:(BOOL)dValue
{
    NSNumber * number = [NSNumber numberWithInt:dValue ? 1 : 0];
    return [[self dictionary:_UISettingDict forKey:key defaultValue:number] boolValue];
}

//no default

- (NSString *)UIStringForKey:(NSString *)key
{
    return [self dictionary:_UISettingDict forKey:key];
}

- (float)UIFloatForKey:(NSString *)key
{
    id result = [self dictionary:_UISettingDict forKey:key];
    if (result == nil) {
        return 0.f;
    }
    return [result floatValue];
}

- (int)UIIntForKey:(NSString *)key
{
    id result = [self dictionary:_UISettingDict forKey:key];
    if (result == nil) {
        return 0;
    }
    return [result intValue];
}

- (NSDictionary *)UIDictionaryForKey:(NSString *)key
{
    return [self dictionary:_UISettingDict forKey:key];
}

- (NSArray *)UIArrayForKey:(NSString *)key
{
    return [self dictionary:_UISettingDict forKey:key];
}

- (BOOL)UIBoolForKey:(NSString *)key
{
    id result = [self dictionary:_UISettingDict forKey:key];
    if (result == nil) {
        return NO;
    }
    return [result boolValue];
}

@end
