//
//  AddonsViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AddonsViewController.h"
#import "KMTableView.h"
#import "AddonsCell.h"
#import "AddonManager.h"

@interface AddonsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet KMTableView *addonsView;
@property (nonatomic) NSArray *preparedAddons;
@end

@implementation AddonsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preparedAddons = [[AddonManager sharedManager] preparedAddons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_addonsView reloadData];
}

- (NSString *)pageNameForTrack
{
    return @"AddonsPage";
}

- (void)pullBack
{
    [self renderPullBack:self.addonsView];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    [_preparedAddons enumerateObjectsUsingBlock:^(AddonData *tAddon, NSUInteger idx, BOOL *stop){
        KMCheckboxTableCell *cell = (KMCheckboxTableCell*)[_addonsView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        AddonData *tmpAddon = [_preparedAddons objectAtIndex:idx];
        if (cell.isChecked) {
            [[AddonManager sharedManager] addAddon:tmpAddon];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentAddonsDidChangedNotification object:nil];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_preparedAddons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddonsCellID"];
    AddonData *tAddon = [_preparedAddons objectAtIndex:indexPath.row];
    cell.addon = tAddon;
    cell.checked = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [(KMTableViewCell *)cell refreshUI];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMCheckboxTableCell *cell = (KMCheckboxTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.checked = !cell.isChecked;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
