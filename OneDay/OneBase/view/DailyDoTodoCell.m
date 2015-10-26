//
//  TodoPropertyCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoTodoCell.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "DailyDoTodoCellListCell.h"
#import "KMTableView.h"

#define ListTopPadding 10.f
#define MinHeight 44.f
#define ListViewWidth 233.f

@interface DailyDoTodoCell () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray *todos;
@end

@implementation DailyDoTodoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo
{
    CGFloat ret = 2*ListTopPadding;
    for (TodoData *todo in dailyDo.todos) {
        ret += [DailyDoTodoCellListCell heightOfCellForToDo:todo];
    }
    ret = MAX(ret, MinHeight);
    return ret;
}

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    
    if (_dailyDo) {
        self.todos = [dailyDo todosSortedByIndex];
        [_listView reloadData];
        
        if ([_todos count] > 0) {
            _listView.hidden = NO;
            self.nameLabel.hidden = YES;
        }
        else {
            _listView.hidden = YES;
            self.nameLabel.hidden = NO;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_todos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DailyDoTodoCellListCell heightOfCellForToDo:[_todos objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TodoPropertyListCellID";
    DailyDoTodoCellListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.checkbox.hidden = ![_dailyDo.addon.showChecked boolValue];
    cell.enumLabel.hidden = [_dailyDo.addon.showChecked boolValue];
    cell.todo = [_todos objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [(KMTableViewCell *)cell refreshUI];
}
@end
