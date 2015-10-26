//
//  GuideViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 13-3-6.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "GuideViewController.h"
#import "KMModelManager.h"

#define NumberOfPages 3


@interface GuideViewCloudCellView : UICollectionViewCell <UIGestureRecognizerDelegate> {
    CGPoint _savedCenter;
}

@property (nonatomic, readonly) BOOL iCloudEnabled;

@property (nonatomic) IBOutlet UIImageView *cloudContentView;
@property (nonatomic) IBOutlet UIImageView *checkmarkWhiteView;
@property (nonatomic) IBOutlet UIImageView *checkmarkGreyView;
@property (nonatomic) IBOutlet UIImageView *arrowWhiteView;
@property (nonatomic) UIPanGestureRecognizer *pan;
@property (nonatomic) UITapGestureRecognizer *singleTap;
@end

@implementation GuideViewCloudCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _pan.delegate = self;
    [self addGestureRecognizer:_pan];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _singleTap.delegate = self;
    _singleTap.numberOfTapsRequired = 1;
    _singleTap.numberOfTouchesRequired = 1;
    [_checkmarkWhiteView addGestureRecognizer:_singleTap];
    
    _savedCenter = _checkmarkWhiteView.center;
}

- (IBAction)handleSingleTap:(id)sender
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (CGPointEqualToPoint(_checkmarkWhiteView.center, _checkmarkGreyView.center)) {
                             _checkmarkWhiteView.center = _savedCenter;
                         }
                         else {
                             _checkmarkWhiteView.center = _checkmarkGreyView.center;
                         }
                     }
                     completion:^(BOOL finished) {
                         _iCloudEnabled = CGPointEqualToPoint(_checkmarkWhiteView.center,
                                                              _checkmarkGreyView.center);
                     }];
}

- (IBAction)handlePan:(id)sender
{
    UIPanGestureRecognizer *pan = sender;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            _checkmarkWhiteView.center = [pan locationInView:self];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 if (CGRectContainsPoint(_cloudContentView.frame, _checkmarkWhiteView.center)) {
                                     _checkmarkWhiteView.center = _checkmarkGreyView.center;
                                 }
                                 else {
                                     _checkmarkWhiteView.center = _savedCenter;
                                 }
                             }
                             completion:^(BOOL finished) {
                                 _iCloudEnabled = CGPointEqualToPoint(_checkmarkWhiteView.center,
                                                                      _checkmarkGreyView.center);
                                        }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _pan) {
        return CGRectContainsPoint(_checkmarkWhiteView.frame, [_pan locationInView:self]);
    }
    else {
        return YES;
    }
}
@end


@interface GuideViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSInteger _currentPage;
}

@property (nonatomic) IBOutlet UICollectionView *guideView;
@property (nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) GuideViewCloudCellView *cloudCellView;
@end

@implementation GuideViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.view.backgroundColor = [UIColor purpleColor];
//    self.guideView.backgroundColor = [UIColor clearColor];
}

- (NSString *)pageNameForTrack
{
    return @"GuidePage";
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger ret = NumberOfPages;
    _pageControl.numberOfPages = ret;
    return ret;
}

static NSString *guideViewCell1ID = @"GuideViewCell1ID";
static NSString *guideViewCloudCellID = @"GuideViewCloudCellID";
static NSString *guideViewLastCellID = @"GuideViewLastCellID";
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *tCell = nil;
    if(0 == indexPath.item) {
        tCell = [collectionView dequeueReusableCellWithReuseIdentifier:guideViewCell1ID forIndexPath:indexPath];
    }
    else if (1 == indexPath.item) {
        tCell = [collectionView dequeueReusableCellWithReuseIdentifier:guideViewCloudCellID forIndexPath:indexPath];
        self.cloudCellView = (GuideViewCloudCellView *)tCell;
    }
    else if (2 == indexPath.item) {
        tCell = [collectionView dequeueReusableCellWithReuseIdentifier:guideViewLastCellID forIndexPath:indexPath];
    }
    return tCell;
}

#pragma mark - UIScrollViewDelegate

- (void)updateCurrentPage:(UIScrollView *)scrollView
{
    _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if(_currentPage < NumberOfPages - 1) {
        _pageControl.currentPage = _currentPage;
    }
    else {
        [self dismiss:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentPage:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateCurrentPage:scrollView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

#pragma mark - Actions

- (IBAction)handleSingleTap:(id)sender
{
    if (_currentPage < NumberOfPages - 1) {
        NSIndexPath *tIndexPath = [NSIndexPath indexPathForItem:_currentPage + 1 inSection:0];
        [_guideView scrollToItemAtIndexPath:tIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^(void) {
        if (_cloudCellView) {
//            [[KMModelManager sharedManager] switchToiCloud:_cloudCellView.iCloudEnabled];
        }
        else {
//            [[KMModelManager sharedManager] switchToiCloud:NO];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(guideViewController:didDismissedAnimation:)]) {
            [_delegate guideViewController:self didDismissedAnimation:NO];
        }
    }];
}
@end
