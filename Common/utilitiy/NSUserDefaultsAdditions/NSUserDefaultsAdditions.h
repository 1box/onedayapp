//
//  NSUserDefaultsAdditions.h
//  Base
//
//  Created by Tu Jianfeng on 6/14/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    firstTimeTypeAppDelegate = 0,
    firstTimeTypeHomePage
} firstTimeType;


@interface NSUserDefaults (SSCategory)

+ (BOOL)currentVersionFirstTimeRunByType:(firstTimeType)type;   // default set 1 when return
+ (BOOL)currentVersionFirstTimeRunByKey:(NSString *)key;
+ (BOOL)firstTimeRunByType:(firstTimeType)type;
+ (BOOL)firstTimeUseKey:(NSString *)aKey;

@end
