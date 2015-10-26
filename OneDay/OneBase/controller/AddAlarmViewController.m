//
//  AddAlarmViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AddAlarmViewController.h"
#import "AlarmRepeatViewController.h"
#import "AlarmInputViewController.h"
#import "KMTableView.h"
#import "KMTableViewCell.h"
#import "AddonData.h"
#import "AlarmData.h"
#import "AlarmManager.h"
#import "KMDateUtils.h"

@interface AddAlarmViewController () <UITableViewDataSource, UITableViewDelegate> {
    BOOL _hasAppear;
}
@end

@implementation AddAlarmViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showAlarmEditRepeatType"]) {
        AlarmRepeatViewController *controller = segue.destinationViewController;
        controller.alarm = _alarm;
    }
    else if ([segue.identifier isEqualToString:@"showAlarmEditText"]) {
        AlarmInputViewController *controller = segue.destinationViewController;
        controller.alarm = _alarm;
    }
}

#pragma mark - View Lifecycles

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_alarm) {
        self.alarm = [[AlarmManager sharedManager] alarmForDictionary:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _nagTypeSwitch.on = ([_alarm.type integerValue] == AlarmNagTypeNag);
    if (_alarm.alarmTime && !_hasAppear) {
        _hasAppear = YES;
        if (_timePicker) {
            _timePicker.date = [HourToMiniteFormatter() dateFromString:_alarm.alarmTime];
        }
    }
    [_listView reloadData];
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
    _alarm.alarmTime = [HourToMiniteFormatter() stringFromDate:_timePicker.date];
    
    [[AlarmManager sharedManager] insertOrUpdateAlarm:_alarm toAddon:_addon];
    [[AlarmManager sharedManager] rebuildAlarmNotifications];
}

- (IBAction)saveAndDismiss:(id)sender
{
    [self save:sender];
    [self dismiss:sender];
}

- (IBAction)saveAndBack:(id)sender
{
    [self save:sender];
    [self back:sender];
}

- (IBAction)switchNagType:(id)sender
{
    UISwitch *aSwitch = sender;
    if (aSwitch.isOn) {
        _alarm.type = [NSNumber numberWithInteger:AlarmNagTypeNag];
    }
    else {
        _alarm.type = [NSNumber numberWithInteger:AlarmNagTypeGentle];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *addAlarmRepeatTypeCellID = @"AddAlarmRepeatTypeCellID";
    static NSString *addAlarmNagTypeCellID = @"AddAlarmNagTypeCellID";
    static NSString *addAlarmTextCellID = @"AddAlarmTextCellID";
    KMTableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:addAlarmRepeatTypeCellID];
            cell.detailTextLabel.text = [_alarm repeatText];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:addAlarmNagTypeCellID];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:addAlarmTextCellID];
            cell.detailTextLabel.text = _alarm.text;
            break;
        default:
            break;
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

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_listView updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

@end
