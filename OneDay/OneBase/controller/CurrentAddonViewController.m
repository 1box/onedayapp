//
//  CurrentAddonViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-6-29.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "CurrentAddonViewController.h"
#import "DailyDoViewController.h"
#import "AddonData.h"
#import "AddonManager.h"

@interface CurrentAddonViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray *currentAddons;
@end

@implementation CurrentAddonViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentAddons = [[AddonManager sharedManager] currentAddons];
    [_listView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentAddons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CurrentAddonCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row < [_currentAddons count]) {
        AddonData *addon = [_currentAddons objectAtIndex:indexPath.row];
        cell.textLabel.text = NSLocalizedString(addon.dailyDoName, nil);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_currentAddons count]) {
        DailyDoViewController *controller = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:DailyDoViewStoryboardID];
        controller.addon = [_currentAddons objectAtIndex:indexPath.row];
        
        UINavigationController *nav = [KMCommon rootNavigationController];
        [nav popToRootViewControllerAnimated:NO];
        [nav pushViewController:controller animated:NO];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
