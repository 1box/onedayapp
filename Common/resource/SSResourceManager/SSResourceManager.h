//
//  SSResourceManager.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSResourceManagerThemeModeChangedNotification @"SSResourceManagerThemeModeChangedNotification"

typedef enum {
	SSThemeModeDay = 0,
	SSThemeModeNight
} SSThemeMode;


@interface SSResourceManager : NSObject

+ (SSResourceManager *)shareBundle;
- (void)switchToThemeMode:(SSThemeMode)themeMode;

//entire
- (NSString *)UIStringForKey:(NSString *)key defaultValue:(NSString *)dValue;
- (float)UIFloatForKey:(NSString *)key defaultValue:(float)dValue;
- (int)UIIntForKey:(NSString *)key defaultValue:(int)dValue;
- (NSDictionary *)UIDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)dDict;
- (NSArray *)UIArrayForKey:(NSString *)key defaultValue:(NSArray *)dArray;
- (BOOL)UIBoolForKey:(NSString *)key defaultValue:(BOOL)dValue;
//no default

- (NSString *)UIStringForKey:(NSString *)key;
- (float)UIFloatForKey:(NSString *)key;
- (int)UIIntForKey:(NSString *)key;
- (NSDictionary *)UIDictionaryForKey:(NSString *)key;
- (NSArray *)UIArrayForKey:(NSString *)key;
- (BOOL)UIBoolForKey:(NSString *)key;


- (NSString *)logicStringForKey:(NSString *)key defaultValue:(NSString *)dValue;
- (float)logicFloatForKey:(NSString *)key defaultValue:(float)dValue;
- (int)logicIntForKey:(NSString *)key defaultValue:(int)dValue;
- (NSDictionary *)logicDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)dDict;
- (NSArray *)logicArrayForKey:(NSString *)key defaultValue:(NSArray *)dArray;
- (BOOL)logicBoolForKey:(NSString *)key defaultValue:(BOOL)dValue;

//no default
- (NSString *)logicStringForKey:(NSString *)key;
- (float)logicFloatForKey:(NSString *)key;
- (int)logicIntForKey:(NSString *)key;
- (NSDictionary *)logicDictionaryForKey:(NSString *)key;
- (NSArray *)logicArrayForKey:(NSString *)key;
- (BOOL)logicBoolForKey:(NSString *)key;

@end

//UI setting

//entire
#define SSUIStringWithComment(key, default, comment) \
[[SSResourceManager shareBundle] UIStringForKey:(key) defaultValue:(default)]

#define SSUIFloatWithComment(key, default, comment) \
[[SSResourceManager shareBundle] UIFloatForKey:(key) defaultValue:(default)]

#define SSUIIntWithComment(key, default, comment) \
[[SSResourceManager shareBundle] UIIntForKey:(key) defaultValue:(default)]

#define SSUIDictionaryWithComment(key, default, comment) \
[[SSResourceManager shareBundle] UIDictionaryForKey:(key) defaultValue:(default)]

#define SSUIArrayWithComment(key, default, comment) \
[[SSResourceManager shareBundle] UIArrayForKey:(key) defaultValue:(default)]

#define SSUIBoolWithComment(key, default, comment) \
[[SSResourceManager shareBundle] UIBoolForKey:(key) defaultValue:(default)]

//no comment
#define SSUIString(key, default) \
[[SSResourceManager shareBundle] UIStringForKey:(key) defaultValue:(default)]

#define SSUIFloat(key, default) \
[[SSResourceManager shareBundle] UIFloatForKey:(key) defaultValue:(default)]

#define SSUIInt(key, default) \
[[SSResourceManager shareBundle] UIIntForKey:(key) defaultValue:(default)]

#define SSUIDictionary(key, default) \
[[SSResourceManager shareBundle] UIDictionaryForKey:(key) defaultValue:(default)]

#define SSUIArray(key, default) \
[[SSResourceManager shareBundle] UIArrayForKey:(key) defaultValue:(default)]

#define SSUIBool(key, default) \
[[SSResourceManager shareBundle] UIBoolForKey:(key) defaultValue:(default)]

//no default
#define SSUIStringNoDefault(key) \
[[SSResourceManager shareBundle] UIStringForKey:(key)]

#define SSUIFloatNoDefault(key) \
[[SSResourceManager shareBundle] UIFloatForKey:(key)]

#define SSUIIntNoDefault(key) \
[[SSResourceManager shareBundle] UIIntForKey:(key)]

#define SSUIDictionaryNoDefault(key) \
[[SSResourceManager shareBundle] UIDictionaryForKey:(key)]

#define SSUIArrayNoDefault(key) \
[[SSResourceManager shareBundle] UIArrayForKey:(key)]

#define SSUIBoolNoDefault(key) \
[[SSResourceManager shareBundle] UIBoolForKey:(key)]


//logic setting
//entire
#define SSLogicStringWithComment(key, default, comment) \
[[SSResourceManager shareBundle] logicStringForKey:(key) defaultValue:(default)]

#define SSLogicFloatWithComment(key, default, comment) \
[[SSResourceManager shareBundle] logicFloatForKey:(key) defaultValue:(default)]

#define SSLogicIntWithComment(key, default, comment) \
[[SSResourceManager shareBundle] logicIntForKey:(key) defaultValue:(default)]

#define SSLogicDictionaryWithComment(key, default, comment) \
[[SSResourceManager shareBundle] logicDictionaryForKey:(key) defaultValue:(default)]

#define SSLogicArrayWithComment(key, default, comment) \
[[SSResourceManager shareBundle] logicArrayForKey:(key) defaultValue:(default)]

#define SSLogicBoolWithComment(key, default, comment) \
[[SSResourceManager shareBundle] logicBoolForKey:(key) defaultValue:(default)]


//no comment

#define SSLogicString(key, default) \
[[SSResourceManager shareBundle] logicStringForKey:(key) defaultValue:(default)]

#define SSLogicFloat(key, default) \
[[SSResourceManager shareBundle] logicFloatForKey:(key) defaultValue:(default)]

#define SSLogicInt(key, default) \
[[SSResourceManager shareBundle] logicIntForKey:(key) defaultValue:(default)]

#define SSLogicDictionary(key, default) \
[[SSResourceManager shareBundle] logicDictionaryForKey:(key) defaultValue:(default)]

#define SSLogicArray(key, default) \
[[SSResourceManager shareBundle] logicArrayForKey:(key) defaultValue:(default)]

#define SSLogicBool(key, default) \
[[SSResourceManager shareBundle] logicBoolForKey:(key) defaultValue:(default)]

//no default
#define SSLogicStringNODefault(key) \
[[SSResourceManager shareBundle] logicStringForKey:(key)]

#define SSLogicFloatNODefault(key) \
[[SSResourceManager shareBundle] logicFloatForKey:(key)]

#define SSLogicIntNODefault(key) \
[[SSResourceManager shareBundle] logicIntForKey:(key)]

#define SSLogicDictionaryNODefault(key) \
[[SSResourceManager shareBundle] logicDictionaryForKey:(key)]

#define SSLogicArrayNODefault(key) \
[[SSResourceManager shareBundle] logicArrayForKey:(key)]

#define SSLogicBoolNODefault(key) \
[[SSResourceManager shareBundle] logicBoolForKey:(key)]

