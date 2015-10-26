//
//  DotLockViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DotLockViewController.h"
#import "NormalCircle.h"
#import "PasswordManager.h"
#import "KMModelManager.h"
#import "AddonData.h"


@interface DotLockViewController () <LockScreenDelegate>
@property (nonatomic) NSInteger wrongGuessCount;
@property (nonatomic) NSNumber *tempPattern;
@end


@implementation DotLockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageType = LockViewPageTypeLaunch;
    }
    return self;
}

- (NSString *)pageNameForTrack
{
    return @"DotLock";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    self.lockScreenView = [[SPLockScreen alloc]initWithFrame:CGRectMake(0, 0, SSWidth(self.view), SSHeight(self.view))];
	_lockScreenView.center = self.view.center;
	_lockScreenView.delegate = self;
	_lockScreenView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_lockScreenView];
    [self.view sendSubviewToBack:_lockScreenView];
    
    switch (_pageType) {
        case LockViewPageTypeLaunch:
        {
            _passwordSwitch.on = [PasswordManager launchPasswordOpen];
            _switchLabel.text = NSLocalizedString(@"LockLaunchSwitchText", nil);
        }
            break;
        case LockViewPageTypeAddon:
        {
            _passwordSwitch.on = [_addon.passwordOn boolValue];
            _switchLabel.text = NSLocalizedString(_addon.dailyDoName, nil);
        }
            break;
        case LockViewPageTypeReset:
        {
            _passwordSwitch.on = [PasswordManager passwordOpen];
            _switchLabel.text = NSLocalizedString(@"LockResetSwitchText", nil);
        }
            break;
            
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateStatus];
}

#pragma mark - Actions

- (IBAction)passwordSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    switch (_pageType) {
        case LockViewPageTypeLaunch:
        {
            [PasswordManager setLaunchPasswordOpen:aSwitch.isOn];
        }
            break;
        case LockViewPageTypeAddon:
        {
            _addon.passwordOn = [NSNumber numberWithBool:aSwitch.isOn];
            [[KMModelManager sharedManager] saveContext:nil];
        }
            break;
        case LockViewPageTypeReset:
        {
            [PasswordManager setPasswordOpen:aSwitch.isOn];
        }
            break;
            
        default:
            break;
    }
    
    if (!aSwitch.isOn) {
        [self dismiss:nil];
    }
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^() {
        if (_delegate && [_delegate respondsToSelector:@selector(lockViewControllerHasDismiss:)]) {
            [_delegate lockViewControllerHasDismiss:self];
        }
        
        if (_finishBlock) {
            _finishBlock(self);
        }
    }];
}

#pragma mark - private

- (void)updateStatus
{
    _passwordSwitch.hidden = (_infoLabelStatus != InfoStatusFirstTimeSetting);
    _switchLabel.hidden = _passwordSwitch.hidden;
    
	switch (self.infoLabelStatus) {
		case InfoStatusFirstTimeSetting:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusFirstTimeSettingText", nil);
			break;
		case InfoStatusConfirmSetting:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusConfirmSettingText", nil);
			break;
		case InfoStatusFailedConfirm:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusFailedConfirmText", nil);
			break;
		case InfoStatusNormal:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusNormalText", nil);
			break;
		case InfoStatusFailedMatch:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusFailedMatchText", nil);
			break;
		case InfoStatusSuccessMatch:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusSuccessMatchText", nil);
			break;
			
		default:
			break;
	}
}

#pragma mark - LockScreenDelegate

- (void)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSNumber *)patternNumber
{
	switch (self.infoLabelStatus) {
		case InfoStatusFirstTimeSetting:
        {
            self.tempPattern = patternNumber;
			self.infoLabelStatus = InfoStatusConfirmSetting;
			[self updateStatus];
        }
			break;
		case InfoStatusFailedConfirm:
		case InfoStatusConfirmSetting:
            if ([patternNumber isEqualToNumber:_tempPattern]) {
                [PasswordManager setDotLockPassword:[_tempPattern stringValue]];
                self.tempPattern = nil;
                [self dismiss:nil];
            }
			else {
				self.infoLabelStatus = InfoStatusFailedConfirm;
				[self updateStatus];
			}
			break;
		case InfoStatusNormal:
		case InfoStatusFailedMatch:
            if ([PasswordManager checkDotLockPassword:[patternNumber stringValue]]) {
                self.infoLabelStatus = InfoStatusSuccessMatch;
                [self updateStatus];
                [self dismiss:nil];
            }
            else {
				self.infoLabelStatus = InfoStatusFailedMatch;
				self.wrongGuessCount ++;
				[self updateStatus];
            }
			break;
		case InfoStatusSuccessMatch:
			[self dismiss:nil];
			break;
		default:
			break;
	}
}

@end

