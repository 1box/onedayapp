//
//  PasswordManager.h
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DotLockViewController.h"

@class AddonData;

@interface PasswordManager : NSObject

+ (PasswordManager *)sharedManager;

- (void)showLaunchLockIfNecessary;
- (void)showAddonLock:(AddonData *)addon finishBlock:(LockViewDismissBlock)finishedBlock;
- (void)showResetLock;
- (void)showLockViewWithInfoStatus:(InfoStatus)status pageType:(LockViewPageType)pageType addon:(AddonData *)addon finishBlock:(LockViewDismissBlock)aBlock;

- (void)resetHasShownAddonDictionary;

+ (BOOL)launchPasswordOpen;
+ (void)setLaunchPasswordOpen:(BOOL)open;

+ (BOOL)passwordOpen;
+ (void)setPasswordOpen:(BOOL)open;

+ (BOOL)hasDotLockPassword;
+ (BOOL)checkDotLockPassword:(NSString *)password;
+ (void)setDotLockPassword:(NSString *)password;

@end
