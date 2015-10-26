//
//  AlarmRepeatViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmRepeatViewController.h"
#import "AlarmData.h"
#import "KMTableView.h"
#import "AlarmRepeatTypeCellView.h"

#define AlarmRepeatTypeCellIDs @[@"SundayCellID", @"MondayCellID", @"TuesdayCellID", @"WednesdayCellID", @"ThursdayCellID", @"FridayCellID", @"SaturdayCellID"]


@interface AlarmRepeatViewController () <UITableViewDataSource, UITableViewDelegate> {
    AlarmRepeatType _repeatType;
}
@property (nonatomic) IBOutlet KMTableView *listView;
@end


@implementation AlarmRepeatViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _repeatType = [_alarm.repeatType integerValue];
}

#pragma mark - private

- (AlarmRepeatType)repeatTypeForRow:(NSInteger)row
{
    AlarmRepeatType repeatType;
    switch (row) {
        case 0:
            repeatType = AlarmRepeatTypeSunday;
            break;
        case 1:
            repeatType = AlarmRepeatTypeMonday;
            break;
        case 2:
            repeatType = AlarmRepeatTypeTuesday;
            break;
        case 3:
            repeatType = AlarmRepeatTypeWednesday;
            break;
        case 4:
            repeatType = AlarmRepeatTypeThursday;
            break;
        case 5:
            repeatType = AlarmRepeatTypeFriday;
            break;
        case 6:
            repeatType = AlarmRepeatTypeSaturday;
            break;
    }
    return repeatType;
}

- (void)updateRepeatType
{
    AlarmRepeatType repeatType = AlarmRepeatTypeNever;
    for (int i=0; i<7; i++) {
        AlarmRepeatTypeCellView *tCell = (AlarmRepeatTypeCellView *)[_listView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (tCell.isChecked) {
            if (repeatType == AlarmRepeatTypeNever) {
                repeatType = [self repeatTypeForRow:i];
            }
            else {
                repeatType |= [self repeatTypeForRow:i];
            }
        }
    }
    _repeatType = repeatType;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMCheckboxTableCell *cell = [tableView dequeueReusableCellWithIdentifier:[AlarmRepeatTypeCellIDs stringWithEnum:indexPath.row]];
    
    AlarmRepeatType repeatType = [self repeatTypeForRow:indexPath.row];
    cell.checked = repeatType == (repeatType & _repeatType);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        AlarmRepeatTypeCellView *cell = (AlarmRepeatTypeCellView*)[tableView cellForRowAtIndexPath:indexPath];
        cell.checked = !cell.isChecked;
        [self updateRepeatType];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    _alarm.repeatType = [NSNumber numberWithInteger:_repeatType];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
