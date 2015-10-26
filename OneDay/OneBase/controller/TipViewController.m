//
//  SmarkTipViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TipViewController.h"
#import "TipCollectCell.h"
#import "AddonManager.h"
#import "AddonData.h"

#define NumberOfMainTips 1
#define NumberOfMoreTips 0

@interface TipViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    
    NSInteger _currentPage;
}
@property (nonatomic) IBOutlet UICollectionView *collectView;
@property (nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic) NSArray *hasTipAddons;
@end

@implementation TipViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"TipPage_%@", _currentAddon.dailyDoName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasTipAddons = [[AddonManager sharedManager] hasTipAddons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_currentAddon) {
        _currentPage = [_hasTipAddons indexOfObject:_currentAddon] + NumberOfMainTips;
        _pageControl.currentPage = _currentPage;
        
        [_collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger ret = [_hasTipAddons count] + NumberOfMainTips + NumberOfMoreTips;
    _pageControl.numberOfPages = ret;
    
    return ret;
}

static NSString *tipCollectCellID = @"TipCollectCellID";
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TipCollectCell *tCell = [collectionView dequeueReusableCellWithReuseIdentifier:tipCollectCellID forIndexPath:indexPath];
    
    NSString *tImageName = nil;
    NSInteger itemCount = [collectionView numberOfItemsInSection:indexPath.section];
    if (indexPath.row < NumberOfMainTips) {
        if (indexPath.row == 0) {
            tImageName = @"main_tip1.png";
        }
    }
    else if (indexPath.row >= itemCount - NumberOfMoreTips) {
    }
    else {
        NSInteger idx = indexPath.row - NumberOfMainTips;
        AddonData *tAddon = [_hasTipAddons objectAtIndex:idx];
        tImageName = tAddon.tipImage;
    }
    
    if (tImageName) {
        if ([KMCommon is568Screen]) {
            tImageName = [NSString stringWithFormat:@"%@%@%@", [tImageName substringToIndex:[tImageName length] - 4], @"-568h", [tImageName substringFromIndex:[tImageName length] - 4]];
        }
        tCell.tipImageView.image = [UIImage imageNamed:tImageName];
        [tCell.tipImageView sizeToFit];
    }
    return tCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for (TipCollectCell *tCell in [_collectView visibleCells]) {
        [tCell.zoomView setZoomScale:1.0 animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _pageControl.currentPage = _currentPage;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _pageControl.currentPage = _currentPage;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _collectView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - Actions

- (IBAction)pageControlClicked:(id)sender
{
    [_collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
