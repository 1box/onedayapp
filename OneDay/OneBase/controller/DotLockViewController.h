//
//  DotLockViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"
#import "SPLockScreen.h"

@class DotLockViewController;
typedef void (^LockViewDismissBlock)(DotLockViewController *controller);

#define DotLockStoryBoardID @"DotLockViewControllerID"

typedef enum {
	InfoStatusFirstTimeSetting = 0,
	InfoStatusConfirmSetting,
	InfoStatusFailedConfirm,
	InfoStatusNormal,
	InfoStatusFailedMatch,
	InfoStatusSuccessMatch
} InfoStatus;

typedef NS_ENUM(NSInteger, LockViewPageType) {
    LockViewPageTypeLaunch,
    LockViewPageTypeAddon,
    LockViewPageTypeReset
};


@class DotLockViewController;
@protocol LockViewControllerDelegate <NSObject>
@optional
- (void)lockViewControllerHasDismiss:(DotLockViewController *)controller;
@end


@class AddonData;

@interface DotLockViewController : KMViewControllerBase

@property (nonatomic, weak) id<LockViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) IBOutlet UILabel *switchLabel;
@property (strong, nonatomic) SPLockScreen *lockScreenView;
@property (nonatomic, strong) IBOutlet UISwitch *passwordSwitch;

@property (nonatomic) InfoStatus infoLabelStatus;
@property (nonatomic) LockViewPageType pageType;
@property (nonatomic, strong) AddonData *addon;
@property (nonatomic, copy) LockViewDismissBlock finishBlock;

- (IBAction)passwordSwitch:(id)sender;

@end
