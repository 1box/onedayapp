//
//  ViewController.m
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "MainViewController.h"
#import "DailyDoViewController.h"
#import "KMAlertView.h"

#import "KMReorderableCollectionViewSnakeLayout.h"
#import "RootCollectCell.h"
#import "RootVerticalToolbar.h"
#import "DarkNavigationBarButton.h"
#import "MTStatusBarOverlay.h"
#import "TipViewController.h"

#import "AddonManager.h"
#import "AddonData.h"
#import "DailyDoManager.h"
#import "DailyDoBase.h"
#import "KMModelManager.h"
#import "TodoData.h"
#import "HintHelper.h"
#import "CartoonManager.h"
#import "TagManager.h"
#import "SplashHelper.h"
#import "AppPageManager.h"

#define NumberOfItems ([KMCommon is568Screen] ? 8 : 6)


@interface MainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, KMReorderableCollectionViewDelegateSnakeLayout, UIGestureRecognizerDelegate, KMAlertViewDelegate> {
    
    NSUInteger _currentPage;
    KMCollectionViewSnakeLayout *_collectionViewLayout;
    
    BOOL _editing;
    BOOL _hasAppear;
}

@property (nonatomic) NSMutableArray *addons;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) HintHelper *hint;

@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat topPadding;
@property (nonatomic) CGFloat leftPadding;
@property (nonatomic) CGFloat cellLeftMargin;
@end


@implementation MainViewController

- (void)awakeFromNib
{
    [self registerNotifications];
}

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMore"] ||
        [[segue identifier] isEqualToString:@"rootShowTipPage"] ||
        [[segue identifier] isEqualToString:@"showPreparedAddons"] ||
        [[segue identifier] isEqualToString:@"rootShowHomeCover"]) {
        
        if ([KMCommon isPadDevice]) {
            UIViewController *destination = [segue destinationViewController];
            destination.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    
    if ([[segue identifier] isEqualToString:@"showDailyDo"]) {
        
        NSIndexPath *indexPath = [[_collectionView indexPathsForSelectedItems] objectAtIndex:0];
        AddonData *tAddon = [_addons objectAtIndex:(indexPath.section * NumberOfItems + indexPath.item)];
        DailyDoViewController *controller = [segue destinationViewController];
        controller.addon = tAddon;
        trackEvent(TrackMainViewEvent, [NSString stringWithFormat:@"%@_enter", controller.addon.dailyDoName]);
    }
    else if ([[segue identifier] isEqualToString:@"rootShowTipPage"]) {
        
        DarkNavigationBarButton *leftButton = [DarkNavigationBarButton buttonWithType:UIButtonTypeCustom];
        [leftButton awakeFromNib];
        leftButton.frame = CGRectMake(5.f, 0, 44.f, 30.f);
        [leftButton setImage:[UIImage imageNamed:@"nav_dismiss.png"] forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        TipViewController *controller = [((UINavigationController*)[segue destinationViewController]).viewControllers objectAtIndex:0];
//        [controller.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"dark_nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
        [leftButton addTarget:controller action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        controller.navigationItem.leftBarButtonItem = leftItem;
    }
    else if ([[segue identifier] isEqualToString:@"showPreparedAddons"]) {
//        _hasAppear = NO;
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        if (!_hint.shown && [SplashHelper sharedHelper].splashFinished) {
            if (hasHintForKey([self mainHintPrefix])) {
                resetHasHintForKey([self mainHintPrefix]);
            }
            
            self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:[self mainHintPrefix]];
            [_hint show];
            [KMCommon playSound:@"shake.mp3"];
        }
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

- (NSString *)mainHintPrefix
{
    return [NSString stringWithFormat:@"OneDay_%@", [KMCommon versionName]];
}

- (NSString *)pageNameForTrack
{
    return @"MainPage";
}

#pragma mark - Viewlifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _collectionViewLayout = (KMCollectionViewSnakeLayout*)_collectionView.collectionViewLayout;
    _currentPage = 0;
    _toolbar.pageLabel.text = [NSString stringWithFormat:@"%d", _currentPage];
    
    // to fix bug on iPhone 4S
    _collectionView.scrollEnabled = NO;
    
    [[SplashHelper sharedHelper] prepareSplashAnimationView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([NSUserDefaults currentVersionFirstTimeRunByType:firstTimeTypeHomePage]) {
        if ([SplashHelper sharedHelper].splashFinished) {
            self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:[self mainHintPrefix]];
            [_hint show];
        }
        else {
            [[SplashHelper sharedHelper] addFinishedBlock:^(SplashHelper *helper){
                self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:[self mainHintPrefix]];
                [_hint show];
            }];
        }
    }
    
    if (!_hasAppear) {
        _hasAppear = YES;
        [self reloadData];
        [self loadHomeCover];
        
        if ([KMCommon isPadDevice]) {
            [[AppPageManager sharedManager] showHomepageForNavigation];
        }
        else {
            [[SplashHelper sharedHelper] addFlipedBlock:^(SplashHelper *helper){
                [[AppPageManager sharedManager] showHomepageForNavigation];
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SplashHelper sharedHelper] splashFlipAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CartoonManager sharedManager] stopChangeCartoonTimer];
}

#pragma mark - Notifications

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportODCurrentCartoonIndexChangedNotification:)
                                                 name:ODCurrentCartoonIndexChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportODCartoonManagerRunAllCartoonsNotification:)
                                                 name:ODCartoonManagerRunAllCartoonsNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportHomeCoverDidSelectedNotification:)
                                                 name:HomeCoverDidSelectedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportCurrentAddonsDidChangedNotification:)
                                                 name:CurrentAddonsDidChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportUIApplicationDidChangeStatusBarOrientationNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ODCartoonManagerRunAllCartoonsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ODCurrentCartoonIndexChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HomeCoverDidSelectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)reportODCurrentCartoonIndexChangedNotification:(NSNotification *)notification
{
    NSInteger idx = [[notification.userInfo objectForKey:kODCurrentCartoonIndexChangedNotificationIndexKey] integerValue];
    
    for (RootCollectCell *tCell in _collectionView.visibleCells) {
        [tCell stopCartoon];
    }
    
    RootCollectCell *tCell = (RootCollectCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
    [tCell startCartoon];
}

- (void)reportODCartoonManagerRunAllCartoonsNotification:(NSNotification *)notification
{
    for (RootCollectCell *tCell in _collectionView.visibleCells) {
        [tCell startCartoon];
    }
}

- (void)reportHomeCoverDidSelectedNotification:(NSNotification *)notification
{
    [self loadHomeCover];
}

- (void)reportCurrentAddonsDidChangedNotification:(NSNotification *)notification
{
    [self reloadData];
}

- (void)reportUIApplicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification
{
    // fix bug
    [_collectionView reloadData];
}

#pragma mark - Actions

- (IBAction)handleBackgroundSingleTap:(id)sender
{
    [self changeEditingStatus:NO];
}

- (IBAction)removeButtonClicked:(id)sender
{
    UIButton *removeButton = sender;
    RootCollectCell *tCell = (RootCollectCell *)removeButton.superview.superview;
    NSIndexPath *tIndexPath = [_collectionView indexPathForCell:tCell];
    
    if (tIndexPath) {
        NSMutableArray *tArray = [[_dataSource objectAtIndex:tIndexPath.section] mutableCopy];
        __strong AddonData *tAddon = [tArray objectAtIndex:tIndexPath.item];
        
        [tArray removeObjectAtIndex:tIndexPath.item];
        [_dataSource replaceObjectAtIndex:tIndexPath.section withObject:tArray];
        
        [tCell stopCartoon];
        [_collectionView deleteItemsAtIndexPaths:@[tIndexPath]];
        
        [[AddonManager sharedManager] removeAddon:tAddon];
    }
    
    [self reloadData];
}

- (IBAction)quickButtonClicked:(id)sender
{
    UIButton *quickButton = sender;
    RootCollectCell *tCell = (RootCollectCell *)quickButton.superview.superview;
    NSIndexPath *tIndexPath = [_collectionView indexPathForCell:tCell];
    
    if (tIndexPath) {
        NSMutableArray *tArray = [[_dataSource objectAtIndex:tIndexPath.section] mutableCopy];
        __strong AddonData *tAddon = [tArray objectAtIndex:tIndexPath.item];
        
        KMAlertView *quickAlert = [[KMAlertView alloc] initWithTitle:NSLocalizedString(tAddon.dailyDoName, nil)
                                                            messages:@[NSLocalizedString(@"_quickEntryMessage", nil)]
                                                            delegate:self];
        quickAlert.userInfo = tAddon;
        [quickAlert show];
    }
}

- (IBAction)clearButtonClicked:(id)sender
{
    [self changeEditingStatus:!_editing];
}

#pragma mark - private

- (void)loadHomeCover
{
    NSString *currentHomeCoverImageName = [NSString stringWithFormat:@"homecover00%d.jpg", homeCoverSelectedIndex() + 1];
    _backgroundView.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:currentHomeCoverImageName]];
    
    trackEvent(@"homecover", currentHomeCoverImageName);
}

- (void)reloadData
{
    [self prepareDataSource];
    [_collectionView reloadData];
    [[CartoonManager sharedManager] startChangeCartoonTimer];
}

- (void)prepareDataSource
{
    self.addons = [[[AddonManager sharedManager] currentAddons] mutableCopy];
    
    NSInteger sectionCount = [_addons count]/NumberOfItems + 1;
    if (_dataSource) {
        [_dataSource removeAllObjects];
    }
    else {
        self.dataSource = [NSMutableArray arrayWithCapacity:sectionCount];
    }
    
    for (int i=0; i < [_addons count]; i=i+NumberOfItems) {
        NSInteger itemCount = NumberOfItems;
        if (i/NumberOfItems == sectionCount - 1) {
            itemCount = [_addons count]%NumberOfItems;
        }
        [_dataSource addObject:[_addons objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, itemCount)]]];
    }
}

- (void)changeEditingStatus:(BOOL)editing
{
    _editing = editing;
    for (UICollectionViewCell *cell in _collectionView.visibleCells) {
        if ([cell isKindOfClass:[RootCollectCell class]]) {
            ((RootCollectCell*)cell).editing = _editing;
        }
    }
}

#pragma mark - KMAlertViewDelegate

- (void)kmAlertView:(KMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *tContent = alertView.textView.text;
        if (!KMEmptyString(tContent)) {
            // 只有每日便签用到了快速添加
            AddonData *tAddon = (AddonData *)alertView.userInfo;
            
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:tAddon];
            TodoData *todo = [todayDo insertNewTodoAtIndex:[todayDo.todos count]];
            todo.content = tContent;
            [[KMModelManager sharedManager] saveContext:nil];
            
            [[MTStatusBarOverlay sharedOverlay] postFinishMessage:NSLocalizedString(@"QuickAddTodoDone", nil) duration:2.f];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _backgroundSingleTap) {
        return _editing;
    }
    else {
        return YES;
    }
}

#pragma mark - KMCollectionViewDelegateSnakeLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.itemWidth, self.itemHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForSectionAtIndex:(NSInteger)section
{
    return _collectionView.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(self.topPadding,
                            self.leftPadding,
                            self.topPadding,
                            _collectionView.bounds.size.width - 2*self.itemWidth - self.leftPadding - self.cellLeftMargin);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger ret = [[_dataSource objectAtIndex:section] count];
    return ret;
}

static NSString *feedCollectCellID = @"FeedCollectCell";
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RootCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:feedCollectCellID forIndexPath:indexPath];
    
    AddonData *addon = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
    cell.addon = addon;
    [cell refreshUI];
    
    cell.editing = _editing;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - KMReorderingCollectionViewDelegateSnakeLayout

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout shouldMoveCellForItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willBeginReorderingItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_editing) {
        [self changeEditingStatus:YES];
    }
    
    RootCollectCell *tCell = (RootCollectCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [tCell stopCartoon];
    tCell.reordering = YES;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willMoveCellForItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *tDataList = [[_dataSource objectAtIndex:fromIndexPath.section] mutableCopy];
    
    __strong id tData = [tDataList objectAtIndex:fromIndexPath.item];
    [tDataList removeObjectAtIndex:fromIndexPath.item];
    [_dataSource replaceObjectAtIndex:fromIndexPath.section withObject:tDataList];
    
    tDataList = [[_dataSource objectAtIndex:toIndexPath.section] mutableCopy];
    [tDataList insertObject:tData atIndex:toIndexPath.item];
    [_dataSource replaceObjectAtIndex:toIndexPath.section withObject:tDataList];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didMoveCellForItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willEndReorderingItemAtIndexPath:(NSIndexPath *)indexPath
{
    int addonIndex = indexPath.item;
    int sectionIndex = 0;
    while (sectionIndex < indexPath.section) {
        NSArray *tArray = [_dataSource objectAtIndex:sectionIndex];
        addonIndex += [tArray count];
        
        sectionIndex ++;
    }
    
    AddonData *tAddon = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
    if (addonIndex < [_addons count]) {
        [[AddonManager sharedManager] moveAddon:tAddon toIndex:addonIndex];
    }
    
    [self reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didEndReorderingItemAtIndexPath:(NSIndexPath *)indexPath
{
    for (UICollectionViewCell *cell in _collectionView.visibleCells) {
        if ([cell isKindOfClass:[RootCollectCell class]]) {
            ((RootCollectCell*)cell).reordering = NO;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [_toolbar spinPageViewWithNumber:_currentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [_toolbar spinPageViewWithNumber:_currentPage];
}

#pragma mark - Layouts

- (CGFloat)itemWidth
{
    if ([KMCommon isPadDevice]) {
        return 180;
    }
    else if ([KMCommon is568Screen]) {
        return 95.f;
    }
    else {
        return 100.f;
    }
}

- (CGFloat)itemHeight
{
    if ([KMCommon isPadDevice]) {
        return 180.f;
    }
    else if ([KMCommon is568Screen]) {
        return 95.f;
    }
    else {
        return 100.f;
    }
}

- (CGFloat)topPadding
{
    return 10.f;
}

- (CGFloat)leftPadding
{
    return 15.f;
}

- (CGFloat)cellLeftMargin
{
    return 10.f;
}
@end
