//
//  UMIconListViewController.m
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMGridViewController.h"
#import "UMUFPImageView.h"
#import <QuartzCore/QuartzCore.h>

#import "UMUFPGridCell.h"
#import "GridViewCellDemo.h"

@interface UMGridViewController ()

@end

@implementation UMGridViewController

static int NUMBER_OF_COLUMNS = 3;
static int NUMBER_OF_APPS_PERPAGE = 15;

- (NSString*)resolutionString
{
    NSString * resolution;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
		resolution = [NSString stringWithFormat:@"%d x %d",(int)([[UIScreen mainScreen] bounds].size.height*[UIScreen mainScreen].scale),(int)([[UIScreen mainScreen] bounds].size.width*[UIScreen mainScreen].scale)];
	}else
    {
		resolution = [NSString stringWithFormat:@"%d x %d",(int)[[UIScreen mainScreen] bounds].size.height,(int)[[UIScreen mainScreen] bounds].size.width];
	}
    
    return resolution;
}

- (void)updateNumberOfColumns:(UIInterfaceOrientation)orientation
{
    NSString *resolution = [self resolutionString];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if ([resolution isEqualToString:@"1136 x 640"])
        {
            NUMBER_OF_COLUMNS = 6;
        }
        else
        {
            NUMBER_OF_COLUMNS = 5;
        }
    }
    else
    {
        NUMBER_OF_COLUMNS = 3;
    }
    
    if ([resolution isEqualToString:@"1136 x 640"])
    {
        NUMBER_OF_APPS_PERPAGE = 18;
    }
    else
    {
        NUMBER_OF_APPS_PERPAGE = 15;
    }
}

/*
 该SDK同时兼容原有产品应用联盟（侧重换量，交叉推广）和友盟新产品UFP（侧重广告管理），创建各种样式相关的view时，需要传入的参数中包含appkey和slotid：
 1. 对于应用联盟的用户，appkey为必填字段，广告数据的获取将依赖于该字段，slotId传nil即可
 2. 对于UFP的用户，slotid为必填字段，广告数据的获取将依赖于该字段，appkey传nil即可
 3. 对于appkey和slotid都非空的情况，将默认按应用联盟处理, 请酌情使用
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"精彩推荐";
    self.view.autoresizesSubviews = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.921 alpha:1.0];
    
    UIApplication *application = [UIApplication sharedApplication];
    [self updateNumberOfColumns:application.statusBarOrientation];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    _mGridView = [[UMUFPGridView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height-navigationBarHeight) appkey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
    _mGridView.datasource = self;
    _mGridView.delegate = self;
    _mGridView.dataLoadDelegate = (id<GridViewDataLoadDelegate>)self;
    _mGridView.autoresizesSubviews = YES;
    _mGridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
//    _mGridView.mAutoFill = YES;
    
    [_mGridView requestPromoterDataInBackground];
    
    [self.view addSubview:_mGridView];
    [_mGridView release];
}

- (void)dealloc
{
    _mGridView.dataLoadDelegate = nil;
    [_mGridView removeFromSuperview];
    _mGridView = nil;
    
    [super dealloc];
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
    
    [self updateNumberOfColumns:interfaceOrientation];
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    _mGridView.frame = CGRectMake(0, frame.size.height, size.width, size.height - frame.size.height);
}

#pragma mark GridViewDataSource

- (NSInteger)numberOfColumsInGridView:(UMUFPGridView *)gridView{
    
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)numberOfAppsPerPage:(UMUFPGridView *)gridView
{
    return NUMBER_OF_APPS_PERPAGE;
}

- (UIView *)gridView:(UMUFPGridView *)gridView cellForRowAtIndexPath:(IndexPath *)indexPath{
    
    GridViewCellDemo *view = [[[GridViewCellDemo alloc] initWithIdentifier:nil] autorelease];
    
    return view;
}

-(void)gridView:(UMUFPGridView *)gridView relayoutCellSubview:(UIView *)view withIndexPath:(IndexPath *)indexPath{
    
    int arrIndex = [gridView arrayIndexForIndexPath:indexPath];
    if (arrIndex < [_mGridView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mGridView.mPromoterDatas objectAtIndex:arrIndex];
        
        GridViewCellDemo *imageViewCell = (GridViewCellDemo *)view;
        imageViewCell.indexPath = indexPath;
        imageViewCell.titleLabel.text = [promoter valueForKey:@"title"];
        
        [imageViewCell.imageView setImageURL:[NSURL URLWithString:[promoter valueForKey:@"icon"]]];
    }
}

#pragma mark GridViewDelegate

- (CGFloat)gridView:(UMUFPGridView *)gridView heightForRowAtIndexPath:(IndexPath *)indexPath
{
    return 80.0f;
}

- (void)gridView:(UMUFPGridView *)gridView didSelectRowAtIndexPath:(IndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)UMUFPGridViewDidLoadDataFinish:(UMUFPGridView *)gridView promotersAmount:(NSInteger)promotersAmount
{
    NSLog(@"%s, %d", __PRETTY_FUNCTION__, promotersAmount);
    
    [gridView reloadData];
}

- (void)UMUFPGridView:(UMUFPGridView *)gridView didLoadDataFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end