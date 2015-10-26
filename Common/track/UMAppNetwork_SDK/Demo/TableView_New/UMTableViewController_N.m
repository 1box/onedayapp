//
//  UMTableViewController_N.m
//  UMUFPDemo
//
//  Created by liuyu on 12/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMTableViewController_N.h"
#import "UMTableViewCell.h"

@interface UMTableViewController_N ()

@end

@implementation UMTableViewController_N

@synthesize mTableView = _mTableView;

- (void)dealloc {
    _mTableView.dataLoadDelegate = nil;
    [_mTableView removeFromSuperview];
    _mTableView = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"_recommendApp", nil);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    
    _mTableView.frame = CGRectMake(0, navigationBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - navigationBarHeight);
    _mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mTableView.rowHeight = 70.0f;
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.backgroundColor = [UIColor clearColor];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mTableView.dataLoadDelegate = (id<UMUFPTableViewDataLoadDelegate>)self;
    [self.view addSubview:_mTableView];
    [_mTableView release];
    
    [_mTableView reloadData];
    
    [_mTableView sendImpressionReportForPromoters:_mTableView.mPromoterDatas]; // 完成已获取广告展示report的发送, 因为提前获取了广告内容，所以需要在广告被真正展示时调用该方法，仅在mShouldSendImpressionReportAutomaticly为NO时，需要手动调用
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    _mTableView.frame = CGRectMake(0, frame.size.height, size.width, size.height - frame.size.height);
}

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0)
    {
        return [_mTableView.mPromoterDatas count] + 1;
    }
    else if (_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0)
    {
        return [_mTableView.mPromoterDatas count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UMUFPTableViewCell";
    
    if (indexPath.row < [_mTableView.mPromoterDatas count])
    {
        UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.row];
        cell.textLabel.text = [promoter valueForKey:@"title"];
        cell.detailTextLabel.text = [promoter valueForKey:@"ad_words"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        
//        int new = 0;
//        if ([promoter valueForKey:@"new"]) // 通过该字段检查广告是否是新的
//        {
//            new = [[promoter valueForKey:@"new"] intValue];
//        }
//        
//        if (1 == new)
//        {
//            // 新广告
//        }
//        else
//        {
//            // 非新广告
//        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"UMUFPTableViewCell2"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UMUFPTableViewCell2"] autorelease];
            UIView *bgimageSel = [[UIView alloc] initWithFrame:cell.bounds];
            bgimageSel.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.4];
            cell.selectedBackgroundView = bgimageSel;
            [bgimageSel release];
        }
        
        for (UIView *view in cell.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *addMoreLabel = [[[UILabel alloc] initWithFrame:CGRectMake(120, 20, 120, 30)] autorelease];
        addMoreLabel.backgroundColor = [UIColor clearColor];
        addMoreLabel.textAlignment = UITextAlignmentCenter;
        addMoreLabel.font = [UIFont systemFontOfSize:14];
        addMoreLabel.text = @"加载中...";
        [cell addSubview:addMoreLabel];
        
        UIActivityIndicatorView *loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        loadingIndicator.backgroundColor = [UIColor clearColor];
        loadingIndicator.frame = CGRectMake(115, 20, 30, 30);
        [loadingIndicator startAnimating];
        [cell addSubview:loadingIndicator];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_mTableView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.row];
        [_mTableView didClickPromoterAtIndex:promoter index:indexPath.row];
    }
}

#pragma mark - UMTableViewDataLoadDelegate methods

//该方法在成功获取广告数据后被调用
- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters {
    
    if ([promoters count] > 0)
    {        
        [_mTableView reloadData];
    }
    else if ([_mTableView.mPromoterDatas count])
    {
        [_mTableView reloadData];
    }
    
    [_mTableView sendImpressionReportForPromoters:promoters]; // 完成新获取广告展示report的发送
}

//该方法在获取广告数据失败后被调用
- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error {
    
    if ([_mTableView.mPromoterDatas count])
    {
        [_mTableView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize contentSize = scrollView.contentSize;
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    float y = contentOffset.y + bounds.size.height - contentInset.bottom;
    if (y > contentSize.height-30)
    {
        if (!_mTableView.mIsAllLoaded && !_mTableView.mIsLoadingMore)
        {
            [_mTableView requestMorePromoterInBackground];
        }
    }    
}

@end