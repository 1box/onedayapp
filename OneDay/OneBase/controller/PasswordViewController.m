//
//  PasswordViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "PasswordViewController.h"
#import "KMTableView.h"
#import "PasswordAddonCell.h"
#import "PasswordManager.h"
#import "AddonManager.h"
#import "KMModelManager.h"
#import "AddonData.h"

@interface PasswordViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet KMTableView *listView;
@property (nonatomic) NSArray *currentAddons;
@end

@implementation PasswordViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([PasswordManager passwordOpen] && [PasswordManager hasDotLockPassword]) {
        [[PasswordManager sharedManager] showLockViewWithInfoStatus:InfoStatusNormal
                                                           pageType:LockViewPageTypeLaunch
                                                              addon:nil
                                                        finishBlock:nil];
    }
    
    self.currentAddons = [[AddonManager sharedManager] currentAddons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_listView reloadData];
}

- (NSString *)pageNameForTrack
{
    return @"PasswordPage";
}

#pragma mark - Actions

- (IBAction)passwordOn:(id)sender
{
    UISwitch *aSwitch = sender;
    
    PasswordAddonCell *tCell = [[KMCommon OSVersion] floatValue] < 7.f ?
                                (PasswordAddonCell *)aSwitch.superview.superview :
                                (PasswordAddonCell *)aSwitch.superview.superview.superview;
    NSIndexPath *indexPath = [_listView indexPathForCell:tCell];
    if (indexPath.section == 0) {
        [PasswordManager setLaunchPasswordOpen:aSwitch.isOn];
    }
    else if (indexPath.section == 1) {
        AddonData *tAddonOn = [_currentAddons objectAtIndex:indexPath.row];
        tAddonOn.passwordOn = [NSNumber numberWithBool:aSwitch.isOn];
        [[KMModelManager sharedManager] saveContext:nil];
    }
}

- (IBAction)closeAll:(id)sender
{
    for (AddonData *addon in _currentAddons) {
        addon.passwordOn = @NO;
    }
    [[KMModelManager sharedManager] saveContext:nil];
    
    [_listView reloadData];
}

- (IBAction)resetPassword:(id)sender
{
    [[PasswordManager sharedManager] showResetLock];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 1;
    if (section == 1) {
        ret = [_currentAddons count];
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PasswordAddonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordAddonCellID"];
    if (indexPath.section == 0) {
        cell.addonLabel.text = NSLocalizedString(@"LaunchPasswordCellText", nil);
        cell.passwordSwitch.on = [PasswordManager launchPasswordOpen];
    }
    else if (indexPath.section == 1) {
        AddonData *tAddon = [_currentAddons objectAtIndex:indexPath.row];
        cell.addonLabel.text = NSLocalizedString(tAddon.dailyDoName, nil);
        cell.passwordSwitch.on = [tAddon.passwordOn boolValue];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

