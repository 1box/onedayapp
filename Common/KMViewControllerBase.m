//
//  KMViewControllerBase.m
//  OneDay
//
//  Created by Kimimaro on 13-5-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface KMViewControllerBase ()

@end

@implementation KMViewControllerBase

+ (NSString *)storyBoardID
{
    return @"";
}

- (NSString *)pageNameForTrack
{
    // should be extended
    return @"KMViewControllerBase";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pullBack];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[KMCommon OSVersion] floatValue] >= 7.f) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }
    [MobClick beginLogPageView:[self pageNameForTrack]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageNameForTrack]];
}

#pragma mark - extend

- (void)pullBack
{
    // should be extended
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - public

- (void)renderPullBack:(UIScrollView *)scrollView
{
    __weak KMViewControllerBase *weakSelf = self;
//    __weak UIScrollView *weakScroll = scrollView;
    [scrollView addPullToRefreshWithActionHandler:^{
        [weakSelf dismiss:nil];
//        [weakScroll.pullToRefreshView stopAnimating];
    }];
}

@end
