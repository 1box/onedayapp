//
//  AddTagViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TagViewController.h"
#import "TagManager.h"
#import "KMTableView.h"
#import "TagViewListCell.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TagData.h"
#import "KMModelManager.h"
#import "NewTagViewController.h"

#define CommonCellHeight 44.f

enum {
    TagsSection,
    ManageSection
};

typedef enum {
    RootLevelCellID,
    SecondLevelCellID
} DoTagsCellID;

#define DoTagsCellIDArray @[@"RootLevelCellID", @"SecondLevelCellID"]

@interface TagViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray *tags;
@end

@implementation TagViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"TagPage_%@", _dailyDo.addon.dailyDoName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showNewTag"]) {
        NewTagViewController *controller = [segue destinationViewController];
        controller.dailyDo = _dailyDo;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tags = [[TagManager sharedManager] tags];
    [_tagsView reloadData];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    [_tags enumerateObjectsUsingBlock:^(TagData *tag, NSUInteger idx, BOOL *stop){
        KMCheckboxTableCell *cell = (KMCheckboxTableCell*)[_tagsView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:TagsSection]];
        TagData *tmpTag = [_tags objectAtIndex:idx];
        if (cell.isChecked) {
            [tmpTag addDailyDosObject:_dailyDo];
        }
        else {
            [tmpTag removeDailyDosObject:_dailyDo];
        }
    }];
    [[KMModelManager sharedManager] saveContext:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TagsSection) {
        return [_tags count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rootLevelCell = [DoTagsCellIDArray stringWithEnum:RootLevelCellID];
    NSString *secondLevelCell = [DoTagsCellIDArray stringWithEnum:SecondLevelCellID];
    
    if (indexPath.section == TagsSection) {
        TagData *tag = [_tags objectAtIndex:indexPath.row];
        
        TagViewListCell *cell = nil;
        if ([tag.level intValue] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:rootLevelCell];
        }
        else if ([tag.level intValue] == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:secondLevelCell];
        }
        
        cell.tagName.text = NSLocalizedString(tag.name, nil);
        cell.checked = [_dailyDo.tags containsObject:tag];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tagsView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TagsSection) {
        KMCheckboxTableCell *cell = (KMCheckboxTableCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.checked = !cell.isChecked;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tagsView updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_tagsView updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

@end
