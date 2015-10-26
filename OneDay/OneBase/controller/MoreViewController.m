//
//  MoreViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MoreViewController.h"
#import "KMTableView.h"
#import "MoreCell.h"
#import "AlarmManager.h"
#import "CartoonManager.h"
#import "KMModelManager.h"
#import "KMDateUtils.h"
#import "UIScrollView+SVPullToRefresh.h"

typedef NS_ENUM(NSInteger, SectionType) {
    SectionTypeSetting = 0,
    SectionTypeTip,
    SectionTypeRate
};

typedef NS_ENUM(NSInteger, TipSectionRowType) {
    TipSectionRowTypeRecommendApp = 0,
    TipSectionRowTypeTips
};

typedef NS_ENUM(NSInteger, SettingSectionRowType) {
    SettingSectionRowTypeRandomCartoonSwitch = 0,
    SettingSectionRowTypePassword,
    SettingSectionRowTypeAlarmSwitch,
    SettingSectionRowTypeAlarmSoundSwitch,
    SettingSectionRowTypeAlarmBadgeSwitch,
    SettingSectionRowTypeAlarmDatePicker
};

typedef NS_ENUM(NSInteger, RateSectionRowType) {
    RateSectionRowTypeRate = 0,
    RateSectionRowTypeShareToFriend,
    RateSectionRowTypeContactUs
};

@interface MoreViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> 

@end

@implementation MoreViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRecommendApp"] ||
        [segue.identifier isEqualToString:@"showFeedback"] ||
        [segue.identifier isEqualToString:@"showContactUs"] ||
        [segue.identifier isEqualToString:@"showTipPage"]) {
        
        UIViewController *tController = [segue destinationViewController];
        
        if ([tController.navigationItem.leftBarButtonItem.customView isKindOfClass:[UIButton class]]) {
            UIButton *tButton = (UIButton*)tController.navigationItem.leftBarButtonItem.customView;
            [tButton addTarget:self action:@selector(segueBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)segueBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)pageNameForTrack
{
    return @"MorePage";
}

- (void)pullBack
{
    [self renderPullBack:self.listView];
}

#pragma mark - private

- (void)showDatePicker
{
    _alarmTimePicker.date = [HourToMiniteFormatter() dateFromString:alarmNotificationFireTimeString()];
    
    if (_pickerContainer.hidden) {
        _pickerContainer.hidden = NO;
        
        CGRect keyboardEndFrame = _pickerContainer.frame;
        keyboardEndFrame.origin.y -= keyboardEndFrame.size.height;
        CGFloat duration = 0.25f;
        
        CGRect tmpFrame = _listView.frame;
        tmpFrame.size.height -= keyboardEndFrame.size.height;
        
        [UIView animateWithDuration:duration animations:^{
            _pickerContainer.frame = keyboardEndFrame;
        } completion:^(BOOL finished) {
            _listView.frame = tmpFrame;
        }];
    }
}

- (void)hideDatePicker
{
    if (!_pickerContainer.hidden) {
        
        CGRect keyboardEndFrame = _pickerContainer.frame;
        keyboardEndFrame.origin.y += keyboardEndFrame.size.height;
        CGFloat duration = 0.2f;
        
        CGRect tmpFrame = _listView.frame;
        tmpFrame.size.height += keyboardEndFrame.size.height;
        
        [UIView animateWithDuration:duration animations:^{
            _pickerContainer.frame = keyboardEndFrame;
            _listView.frame = tmpFrame;
        } completion:^(BOOL finished) {
            _pickerContainer.hidden = YES;
        }];
    }
}

#pragma mark - Actions

- (IBAction)alarmSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    setAlarmNotificationSwitch(aSwitch.on);
    
    [_listView reloadData];
}

- (IBAction)alarmSoundSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    setPlayAlarmSounds(aSwitch.on);
}

- (IBAction)alarmBadgeSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    setShowAppIconBadge(aSwitch.on);
}

- (IBAction)randomCartoonSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    setRandomCartoonSwitch(aSwitch.on);
    
    [[CartoonManager sharedManager] startChangeCartoonTimer];
}

- (IBAction)pickerCanceled:(id)sender
{
    [self hideDatePicker];
}

- (IBAction)pickerConfirmed:(id)sender
{
    setAlarmNotificationFireTimeString([HourToMiniteFormatter() stringFromDate:_alarmTimePicker.date]);
    [self hideDatePicker];
    
    [_listView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    switch (section) {
        case SectionTypeTip:
            ret = 2;
            break;
        case SectionTypeSetting:
            ret = alarmNotificationSwitch() ? 6 : 3;
            break;
        case SectionTypeRate:
            ret = 3;
            break;
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *randomCartoonCellID = @"MoreViewRandomCartoonSwitchCellID";
    static NSString *passwordCellID = @"MoreViewPasswordCellID";
    static NSString *alarmSwitchCellID = @"MoreViewAlarmSwitchCellID";
    static NSString *alarmSoundSwitchCellID = @"MoreViewAlarmSoundSwitchCellID";
    static NSString *alarmBadgeSwitchCellID = @"MoreViewAlarmBadgeSwitchCellID";
    static NSString *alarmPickerCellID = @"MoreViewAlarmPickerCellID";
    static NSString *recommendAppCellID = @"MoreViewRecommendAppCellID";
    static NSString *tipsCellID = @"MoreViewTipsCellID";
    static NSString *rateCellID = @"MoreViewRateCellID";
    static NSString *shareToFriendsCellID = @"MoreViewShareToFriendsCellID";
    static NSString *contactUsCellID = @"MoreViewContactUsCellID";
    
    NSString *tCellID = nil;
    NSString *detailString = nil;
    
    switch (indexPath.section) {
        case SectionTypeTip:
        {
            switch (indexPath.row) {
                case TipSectionRowTypeRecommendApp:
                    tCellID = recommendAppCellID;
                    break;
                case TipSectionRowTypeTips:
                    tCellID = tipsCellID;
                    break;
            }
        }
            break;
        case SectionTypeSetting:
        {
            switch (indexPath.row) {
                case SettingSectionRowTypeRandomCartoonSwitch:
                {
                    tCellID = randomCartoonCellID;
                    _randomCartoonSwitch.on = randomCartoonSwitch();
                }
                    break;
                case SettingSectionRowTypePassword:
                {
                    tCellID = passwordCellID;
                }
                    break;
                case SettingSectionRowTypeAlarmSwitch:
                {
                    tCellID = alarmSwitchCellID;
                    _alarmSwitch.on = alarmNotificationSwitch();
                }
                    break;
                case SettingSectionRowTypeAlarmDatePicker:
                {
                    tCellID = alarmPickerCellID;
                    detailString = alarmNotificationFireTimeString();
                }
                    break;
                case SettingSectionRowTypeAlarmSoundSwitch:
                {
                    tCellID = alarmSoundSwitchCellID;
                    _alarmSoundSwitch.on = playAlarmSounds();
                    _alarmSoundSwitch.hidden = NO;
                }
                    break;
                case SettingSectionRowTypeAlarmBadgeSwitch:
                {
                    tCellID = alarmBadgeSwitchCellID;
                    _alarmBadgeSwitch.on = showAppIconBadge();
                    _alarmBadgeSwitch.hidden = NO;
                }
                    break;
            }
        }
            break;
        case SectionTypeRate:
        {
            switch (indexPath.row) {
                case RateSectionRowTypeShareToFriend:
                    tCellID = shareToFriendsCellID;
                    break;
                case RateSectionRowTypeRate:
                    tCellID = rateCellID;
                    break;
                case RateSectionRowTypeContactUs:
                    tCellID = contactUsCellID;
                    break;
            }
        }
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tCellID];
    if (detailString) {
        cell.detailTextLabel.text = detailString;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *ret = nil;
    if (section == SectionTypeRate) {
#ifdef DEBUG
        ret = [NSString stringWithFormat:@"Debug: %s %s\nv%@", __DATE__, __TIME__, [KMCommon versionName]];
#else
        ret = [NSString stringWithFormat:@"©onebox design v%@", [KMCommon versionName]];
#endif
    }
    return ret;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionTypeTip:
            break;
        case SectionTypeSetting:
        {
            switch (indexPath.row) {
                case SettingSectionRowTypeAlarmSwitch:
                    break;
                case SettingSectionRowTypeAlarmDatePicker:
                {
                    [self showDatePicker];
                }
                    break;
            }
        }
            break;
        case SectionTypeRate:
        {
            switch (indexPath.row) {
                case RateSectionRowTypeShareToFriend:
                {
                    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share to friends", nil)
                                                                        delegate:self
                                                               cancelButtonTitle:nil
                                                          destructiveButtonTitle:nil
                                                               otherButtonTitles:nil];
                    
                    int cancelIndex = 0;
                    if ([MFMailComposeViewController canSendMail]) {
                        [sheet addButtonWithTitle:NSLocalizedString(@"Email", nil)];
                        cancelIndex ++;
                    }
                    
                    if ([MFMessageComposeViewController canSendText]) {
                        [sheet addButtonWithTitle:NSLocalizedString(@"Message", nil)];
                        cancelIndex ++;
                    }
                    
                    [sheet addButtonWithTitle:NSLocalizedString(@"_cancel", nil)];
                    sheet.cancelButtonIndex = cancelIndex;
                    
                    [sheet showInView:self.view];
                }
                    break;
                case RateSectionRowTypeRate:
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/yi-tian/id573096972?ls=1&mt=8"]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:NSLocalizedString(@"Email", nil)]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            controller.mailComposeDelegate = self;
            [controller setSubject:NSLocalizedString(@"Share app mail subject", nil)];
            [controller setMessageBody:NSLocalizedString(@"Share app mail message", nil) isHTML:NO];
            if (controller) [self.navigationController presentViewController:controller animated:YES completion:nil];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"Message", nil)]) {
            MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            controller.messageComposeDelegate = self;
            controller.body = NSLocalizedString(@"Share app message body", nil);
            if (controller) [self.navigationController presentViewController:controller animated:YES completion:nil];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
