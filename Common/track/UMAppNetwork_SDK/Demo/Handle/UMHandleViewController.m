//
//  UMHandleViewController.m
//  UFP
//
//  Created by liu yu on 8/1/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMHandleViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UMHandleViewController ()

@end

@implementation UMHandleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    
    _mHandleView.delegate = nil;
    [_mHandleView removeFromSuperview];
    [_mHandleView release];
    _mHandleView = nil;
    
    [super dealloc];
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
    
    self.navigationItem.title = @"HandleView";
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageview.image = [UIImage imageNamed:@"placeholder.png"];
    [self.view insertSubview:imageview atIndex:0];
    [imageview release];
            
    _mHandleView = [[UMUFPHandleView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-88, 32, 88) appKey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
    _mHandleView.delegate = (id<UMUFPHandleViewDelegate>)self;
    _mHandleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//    handleView.mNewPromoterNoticeEnabled = NO; // 可开关默认的新广告数目提示，默认为打开
    [_mHandleView setHandleViewBackgroundImage:[UIImage imageNamed:@"UMUFP.bundle/um_handle_placeholder.png"]];
    [self.view addSubview:_mHandleView];
}

- (void)viewWillAppear:(BOOL)animated // 在此调用，可保证在该页面出现时，数据总能得到刷新
{
    [super viewWillAppear:animated];
    
    [_mHandleView requestPromoterDataInBackground];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - UMUFPHandleView delegate methods

- (void)handleViewWillAppear:(UMUFPHandleView *)handleView // 可通过该方法，修改小把手出现时的默认动画
{
    
//    CATransition *animation = [CATransition animation]; 
//    animation.duration = 0.3f; 
//    animation.timingFunction = UIViewAnimationCurveEaseInOut; 
//    animation.fillMode = kCAFillModeBoth; 
//    animation.type = kCATransitionMoveIn; 
//    animation.subtype = kCATransitionFromTop; 
//    [handleView.layer addAnimation:animation forKey:@"animation"];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didClickHandleView:(UMUFPHandleView *)handleView // 该方法在小把手被点击 拉起 时调用
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)handleViewDidPackUp:(UMUFPHandleView *)handleView // 该方法在小把手被点击 收起 时调用
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didClickHandleView:(UMUFPHandleView *)handleView urlToLoad:(NSURL *)url // 实现该方法就可以接管本来需要通过SDK内置webview打开的广告
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didLoadDataFailWithError:(UMUFPHandleView *)handleView error:(NSError *)error // 该方法在 小把手获取广告数据失败 时被调用
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didClickedPromoterAtIndex:(UMUFPHandleView *)handleView index:(NSInteger)promoterIndex promoterData:(NSDictionary *)promoterData // 该方法在 小把手内部广告被点击 时调用
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
