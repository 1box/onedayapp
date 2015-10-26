//
//  UndosViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "UndoViewController.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoBase.h"
#import "KMTableView.h"
#import "UndoCellView.h"
#import "KMLoadMoreCell.h"
#import "MTStatusBarOverlay.h"
#import "TodoManager.h"
#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "KMDateUtils.h"


@interface UndoDateGroupedData : NSObject
@property (nonatomic) NSArray *dataList;
@property (nonatomic) NSDate *lastDate;
@property (nonatomic) NSString *dateString;
@end


@interface UndoViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    BOOL _isLoading;
    BOOL _canLoadMore;
    
    BOOL _hasChecked;
    BOOL _hasMoved;
}
@property (nonatomic) IBOutlet KMTableView *undosView;
@property (nonatomic) NSArray *undos;
@property (nonatomic) NSArray *groupedUndos;
@end


@implementation UndoViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportTodoManagerUndosLoadFinishedNotification:)
                                                 name:TodoManagerUndosLoadFinishedNotification
                                               object:[TodoManager sharedManager]];
    self.undos = [NSArray array];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TodoManagerUndosLoadFinishedNotification object:[TodoManager sharedManager]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadUndos:NO];
}

- (void)pullBack
{
    [self renderPullBack:self.undosView];
}

#pragma mark - Load Data

- (void)reportTodoManagerUndosLoadFinishedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *condition = [userInfo objectForKey:kTodoManagerUndosLoadConditionKey];
    if ([condition objectForKey:kTodoManagerLoadConditionAddonKey] != _addon) {
        return;
    }
    
    NSDictionary *result = [userInfo objectForKey:kTodoManagerUndosLoadResultKey];
    NSError *error = [result objectForKey:kTodoManagerLoadResultErrorKey];
    if (!error) {
        NSArray *dataList = [result objectForKey:kTodoManagerLoadResultDataListKey];
        if ([dataList count] > 0) {
            NSMutableArray *mutUndos = [NSMutableArray arrayWithArray:_undos];
            [mutUndos addObjectsFromArray:dataList];
            self.undos = [mutUndos copy];
        }
        
        _canLoadMore = [dataList count] > 0;
        
        [self prepareDataSource];
        [_undosView reloadData];
    }
    else {
        _canLoadMore = NO;
    }
    
    _isLoading = NO;
}

- (void)loadUndos:(BOOL)loadMore
{
    if (!_isLoading) {
        _isLoading = YES;
        
        NSMutableDictionary *mutCondition = [NSMutableDictionary dictionaryWithDictionary:
                                             @{ kTodoManagerLoadConditionCountKey : [NSNumber numberWithInt:20],
                                                kTodoManagerLoadConditionIsLoadMoreKey : [NSNumber numberWithBool:loadMore],
                                                kTodoManagerLoadConditionAddonKey : _addon}];
        if ([_undos count] > 0 && loadMore) {
            TodoData *todo = [_undos lastObject];
            [mutCondition setObject:todo.dailyDo.createTime forKey:kTodoManagerLoadConditionMaxCreateTimeKey];
        }
        [[TodoManager sharedManager] loadUndosForCondition:[mutCondition copy]];
    }
}

- (void)prepareDataSource
{
    if ([_undos count] > 0) {
        NSMutableArray *tGrouped = [NSMutableArray array];
        NSMutableArray *tDataList = [NSMutableArray array];
        
        NSDate *lastDate = [NSDate date];
        for (TodoData *tData in _undos) {
            NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[tData.dailyDo.createTime doubleValue]];
            if ([currentDate isSameDayWithDate:lastDate]) {
                [tDataList addObject:tData];
            }
            else {
                if ([tDataList count] > 0) {
                    UndoDateGroupedData *tGroupedData = [[UndoDateGroupedData alloc] init];
                    tGroupedData.dataList = [tDataList copy];
                    tGroupedData.lastDate = lastDate;
                    tGroupedData.dateString = [YearToDayWeekFormatter() stringFromDate:lastDate];
                    [tGrouped addObject:tGroupedData];
                }
                
                [tDataList removeAllObjects];
                [tDataList addObject:tData];
            }
            
            lastDate = currentDate;
        }
        
        if ([tDataList count] > 0) {
            UndoDateGroupedData *tGroupedData = [[UndoDateGroupedData alloc] init];
            tGroupedData.dataList = [tDataList copy];
            tGroupedData.lastDate = lastDate;
            tGroupedData.dateString = [YearToDayWeekFormatter() stringFromDate:lastDate];
            [tGrouped addObject:tGroupedData];
        }
        
        self.groupedUndos = [tGrouped copy];
    }
    else {
        self.groupedUndos = [NSArray array];
    }
}

#pragma mark - Actions

- (IBAction)moveAllToTomorrow:(id)sender
{
    if (_hasMoved) {
        return;
    }
    
    DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:_addon];
    [_undos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        if (todo.dailyDo != todayDo) {
            todo.dailyDo = todayDo;
        }
    }];
    [todayDo reorderTodos:NO];
    
    [[KMModelManager sharedManager] saveContext:nil];
    _hasMoved = YES;
    
    [self prepareDataSource];
    [_undosView reloadData];
    
    [[MTStatusBarOverlay sharedOverlay] postFinishMessage:NSLocalizedString(@"MoveAllUndosToToday", nil) duration:2.f];
}

- (IBAction)checkAll:(id)sender
{
    if (_hasChecked) {
        return;
    }
    
    [_undos enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        if (![todo.check boolValue]) {
            todo.check = @YES;
        }
    }];
    
    [[KMModelManager sharedManager] saveContext:nil];
    _hasChecked = YES;
    
    [_undosView reloadData];
    
    [[MTStatusBarOverlay sharedOverlay] postFinishMessage:NSLocalizedString(@"CheckAllUndos", nil) duration:2.f];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_undosView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_groupedUndos count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UndoDateGroupedData *groupedData = [_groupedUndos objectAtIndex:section];
    NSInteger ret = [groupedData.dataList count];
    if (section == [_groupedUndos count] - 1 && _canLoadMore) {
        ret ++;
    }
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UndoDateGroupedData *groupedData = [_groupedUndos objectAtIndex:indexPath.section];
    CGFloat ret = 44.f;
    if (indexPath.section != [_groupedUndos count] - 1 ||
        indexPath.row != [groupedData.dataList count]) {
        ret = [UndoCellView heightForTodoData:[groupedData.dataList objectAtIndex:indexPath.row]];
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *undoCellID = @"UndoCellID";
    static NSString *loadMoreCellID = @"LoadMoreCellID";
    
    UndoDateGroupedData *groupedData = [_groupedUndos objectAtIndex:indexPath.section];
    if (indexPath.section == [_groupedUndos count] - 1 &&
        indexPath.row == [groupedData.dataList count]) {
        
        KMLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellID];
        cell.loading = YES;
        
        [self performBlock:^{
            [self loadUndos:YES];
        } afterDelay:0.1f];
        
        return cell;
    }
    else {
        UndoCellView *cell = [tableView dequeueReusableCellWithIdentifier:undoCellID];
        cell.todo = [groupedData.dataList objectAtIndex:indexPath.row];
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    UndoDateGroupedData *groupedData = [_groupedUndos objectAtIndex:section];
    NSString *ret = groupedData.dateString;
    if ([groupedData.lastDate isToday]) {
        ret = @"今天";
    }
    else if ([groupedData.lastDate isTomorrow]) {
        ret = @"明天";
    }
    return ret;
}

@end


@implementation UndoDateGroupedData
@end
