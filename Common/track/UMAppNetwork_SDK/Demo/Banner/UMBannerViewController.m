//
//  UMBannerViewController.m
//  UFP
//
//  Created by liu yu on 5/14/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMBannerViewController.h"

@implementation UMBannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
            
    banner.delegate = nil;
    [banner removeFromSuperview];
    banner = nil;
        
    [super dealloc];
}

#pragma mark - View lifecycle

/*
 该SDK同时兼容原有产品应用联盟（侧重换量，交叉推广）和友盟新产品UFP（侧重广告管理），创建各种样式相关的view时，需要传入的参数中包含appkey和slotid：
 1. 对于应用联盟的用户，appkey为必填字段，广告数据的获取将依赖于该字段，slotId传nil即可
 2. 对于UFP的用户，slotid为必填字段，广告数据的获取将依赖于该字段，appkey传nil即可
 3. 对于appkey和slotid都非空的情况，将默认按应用联盟处理, 请酌情使用
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"BannerView";
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageview.image = [UIImage imageNamed:@"placeholder.png"];
    [self.view insertSubview:imageview atIndex:0];
    [imageview release];
    
    banner = [[UMUFPBannerView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-320)/2, self.view.bounds.size.height-50, 320, 50) appKey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
    banner.mTextColor = [UIColor whiteColor];
    banner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    banner.delegate = (id<UMUFPBannerViewDelegate>)self;
    [self.view addSubview:banner];
    [banner release];
    [banner requestPromoterDataInBackground];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

#pragma mark - UMUFPBannerView delegate methods

//该方法在广告获取成功时调用
- (void)UMUFPBannerView:(UMUFPBannerView *)_banner didLoadDataFinish:(NSInteger)promotersAmount {
    
    NSLog(@"%s, amount:%d", __PRETTY_FUNCTION__, promotersAmount);
}

//该方法在广告获取失败时调用
- (void)UMUFPBannerView:(UMUFPBannerView *)banner didLoadDataFailWithError:(NSError *)error {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

//实现该方法将可以捕获banner即将出现这一事件，自定义banner首次展示的动画
//- (void)bannerWillAppear:(UMUFPBannerView *)_banner {
//    
//    _banner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.6f];
//    _banner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    [UIView commitAnimations];
//    
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
//}

//该方法在广告被点击后调用
- (void)UMUFPBannerView:(UMUFPBannerView *)_banner didClickedPromoterAtIndex:(NSInteger)index {
    
    NSLog(@"%s, index:%d", __PRETTY_FUNCTION__, index);    
}

//实现该方法将接管本该以webview打开的广告
//- (void)UMUFPBannerView:(UMUFPBannerView *)banner didClickPromoterForUrl:(NSURL *)url
//{
//    //
//}

//实现该方法，将可以处理特殊schema(schema为：callback)的url
//- (void)UMUFPBannerView:(UMUFPBannerView *)banner openAdsForFlag:(NSString *)flagStr
//{
//    
//}

@end
