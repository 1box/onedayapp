//
//  UMTableViewController_New.m
//  UMAppNetworkDemo
//
//  Created by liuyu on 4/18/13.
//  Copyright (c) 2013 Realcent. All rights reserved.
//

#import "UMTableViewController_New.h"
#import "UMTableViewController_N.h"

@interface UMTableViewController_New ()

@end

@implementation UMTableViewController_New

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {

    _mTableView.dataLoadDelegate = nil;
    [_mTableView release];
    _mTableView = nil;
    [badgeView release];
    badgeView = nil;
    
    [super dealloc];
}

- (void)setupReommendBtn
{
    recommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recommentBtn.frame = CGRectMake(20, 100, 120, 37);
    [recommentBtn setTitle:@"应用推荐" forState:UIControlStateNormal];
    [recommentBtn setBackgroundImage:[[UIImage imageNamed:@"um_download_normal.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:10] forState:UIControlStateNormal];
    [recommentBtn setBackgroundImage:[[UIImage imageNamed:@"um_download_selected.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:10] forState:UIControlStateHighlighted];
    [recommentBtn addTarget:self action:@selector(showTableView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recommentBtn];
    
    badgeView = [[UMUFPBadgeView alloc] initWithFrame:CGRectMake(recommentBtn.bounds.size.width-18, -3, 22, 23)];
    [recommentBtn addSubview:badgeView];
    badgeView.hidden = YES;
    
    _mTableView = [[UMUFPTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain appkey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
    _mTableView.mShouldSendImpressionReportAutomaticly = NO; // 关闭默认的获取广告后立马进行展示report发送的逻辑，关闭后需自行完成展示report的发送
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
    
    self.navigationItem.title = @"TableView + New";
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageview.image = [UIImage imageNamed:@"placeholder.png"];
    [self.view insertSubview:imageview atIndex:0];
    [imageview release];
    
    [self setupReommendBtn]; // 自定义集成 新广告提示 的实践
}

- (void)viewWillAppear:(BOOL)animated // 在此调用，可保证在该页面出现时，数据总能得到刷新
{
    [super viewWillAppear:animated];
        
    _mTableView.dataLoadDelegate = (id<UMUFPTableViewDataLoadDelegate>)self; // 设置回调，用于处理新内容提示
    [_mTableView requestPromoterDataInBackground]; // 请求数据
}

- (void)showTableView {
    
    UMTableViewController_N *controller = [[UMTableViewController_N alloc] init];
    controller.mTableView = _mTableView;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    [badgeView updateNewMessageCount:-1]; // badge归零
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

#pragma mark - UMTableViewDataLoadDelegate methods

//该方法在成功获取广告数据后被调用
- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters {
    
    if (_mTableView.mNewPromoterCount >= 0) // 有新广告
    {
        [badgeView updateNewMessageCount:_mTableView.mNewPromoterCount];
    }
    else
    {
        [badgeView updateNewMessageCount:-1]; // 没有新广告
    }
}

//该方法在获取广告数据失败后被调用
- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error {
    
}

@end