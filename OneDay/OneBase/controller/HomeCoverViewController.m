//
//  HomeCoverViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-4-5.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "HomeCoverViewController.h"
#import "UIScrollView+SVPullToRefresh.h"


@implementation HomeCoverCellView
@end


@interface HomeCoverViewController ()
@end


@implementation HomeCoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak HomeCoverViewController *weakSelf = self;
    [self.collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf dismiss:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"HomeCover"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HomeCover"];
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"HomeCoverCellID";
    
    HomeCoverCellView *tCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    tCell.contentImage.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"homecover%03d.jpg", indexPath.item + 1]]];
    
    if (indexPath.item == homeCoverSelectedIndex()) {
        setFrameWithOrigin(_checkmark, SSWidth(tCell) - SSWidth(_checkmark), 0);
        [tCell addSubview:_checkmark];
    }
    return tCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    setHomeCoverSelectedIndex(indexPath.item);
    [self dismiss:self];
}

@end
