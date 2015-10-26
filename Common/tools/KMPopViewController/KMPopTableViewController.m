//
//  KMPopTableViewController.m
//  Drawus
//
//  Created by Tianhang Yu on 12-4-4.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "KMPopTableViewController.h"

#define TABLE_VIEW_WIDTH 290.f
#define TABLE_VIEW_ORIGIN_UP 50.f

@interface KMPopTableViewController () <UITableViewDataSource, UITableViewDelegate> 

@property (nonatomic, retain) UITableView    *tableView;

@end

@implementation KMPopTableViewController

@synthesize tableView  =_tableView;

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    CGRect vFrame = self.view.bounds;

    CGRect tFrame = vFrame;
    tFrame.origin.x    = (tFrame.size.width - TABLE_VIEW_WIDTH) / 2;
    tFrame.size.width  = TABLE_VIEW_WIDTH;

    self.tableView = [[[UITableView alloc] initWithFrame:tFrame style:UITableViewStyleGrouped] autorelease];
    _tableView.dataSource = self;
    _tableView.delegate   = self;
    [_tableView setBackgroundView:nil];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
}

- (void)dealloc
{
    self.tableView = nil;

    [super dealloc];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) 
    {
        return (tableView.frame.size.height - [self cellHeight] * [self cellCount] - TABLE_VIEW_ORIGIN_UP) / 2;
    }
    else 
    {
        return 0.f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self cellCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *titleCellIdentifier   = @"title_cell_identifier";
    static NSString *normalCellIdentifier  = @"normal_cell_identifier";

    if (indexPath.row == 0)
    {
        UITableViewCell *cell = nil;

        cell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (indexPath.section == 0)
        {
            cell.backgroundColor = [UIColor colorWithHexString:@"#ffc555"];
            cell.textLabel.text = @"tableView title"; 
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }

        return cell;
    }
    else if (indexPath.section == 0)
    {
        return [self tableView:tableView cellForRowAtIndexPath:indexPath identifier:normalCellIdentifier];
    }
    else
    {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        // do nothing
    }
    else 
    {
        if (indexPath.section == 0) {
            [self didSelectRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark - extend methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier
{
    // should be extendes

    return nil;
}

- (NSInteger)cellCount
{
    // should be extendes

    return 0;
}

- (CGFloat)cellHeight
{
    // should be extendes

    return 0.f;
}

- (NSString *)tableViewTitle
{
    // should be extendes

    return nil;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // should be extendes
}

#pragma mark - default

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
