//
//  KMNavigationController.m
//  Drawus
//
//  Created by Tianhang Yu on 12-3-24.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "KMNavigationController.h"

#define NAV_PADDING_X 5.f
#define NAV_PADDING_Y 0.f

@interface KMNavigationController ()

@end

@implementation KMNavigationController

@synthesize kmNavigationBar =_kmNavigationBar;

@synthesize titleView       =_titleView;
@synthesize leftView        =_leftView;
@synthesize rightView       =_rightView;
@synthesize animationView   =_animationView;

#pragma mark - public

- (void)setTitleView:(UIView *)titleView
{
	[_titleView removeFromSuperview];
	[_titleView release];
	_titleView = [titleView retain];
    
    CGRect aFrame = _titleView.frame;
    aFrame.size.width = aFrame.size.width * (_kmNavigationBar.frame.size.height - 2*NAV_PADDING_Y) / aFrame.size.height;
    aFrame.size.height = _kmNavigationBar.frame.size.height - 2*NAV_PADDING_Y;
    _titleView.frame = aFrame;

    _titleView.center = CGPointMake(_kmNavigationBar.frame.size.width / 2, _kmNavigationBar.frame.size.height / 2);
    
	[_kmNavigationBar addSubview:_titleView];
}

- (void)setLeftView:(UIView *)leftView
{
	[_leftView removeFromSuperview];
	[_leftView release];
	_leftView = [leftView retain];

    CGRect aFrame = _leftView.frame;
    aFrame.origin.x = NAV_PADDING_X;
    aFrame.origin.y = NAV_PADDING_Y;
    aFrame.size.width = _kmNavigationBar.frame.size.height - 2*NAV_PADDING_Y / aFrame.size.height;
    aFrame.size.height = _kmNavigationBar.frame.size.height - 2*NAV_PADDING_Y;
    _leftView.frame = aFrame;

	[_kmNavigationBar addSubview:_leftView];
}

- (void)setRightView:(UIView *)rightView
{
	[_rightView removeFromSuperview];
	[_rightView release];
	_rightView = [rightView retain];
    
    CGRect aFrame = _rightView.frame;
    aFrame.size.width = _kmNavigationBar.frame.size.height - 2*NAV_PADDING_Y / aFrame.size.height;
    aFrame.size.height = _kmNavigationBar.frame.size.height - 2*NAV_PADDING_Y;
    aFrame.origin.x = _kmNavigationBar.frame.size.width - aFrame.size.width - NAV_PADDING_X;
    aFrame.origin.y = NAV_PADDING_Y;
    _rightView.frame = aFrame;
    
	[_kmNavigationBar addSubview:_rightView];
}

- (void)setKmNavigationBar:(KMNavigationBar *)kmNavigationBar
{
    [_kmNavigationBar removeFromSuperview];
    
    [_kmNavigationBar release];
    _kmNavigationBar = [kmNavigationBar retain];
    
    [self.view addSubview:_kmNavigationBar];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.kmNavigationBar = [[[KMNavigationBar alloc] initWithFrame:self.navigationBar.frame] autorelease];
    [self.view addSubview:_kmNavigationBar];

    self.animationView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    [self.view addSubview:_animationView];

    [self.view sendSubviewToBack:_animationView];
}

- (void)dealloc
{
    self.kmNavigationBar = nil;
    
    self.titleView       = nil;
    self.leftView        = nil;
    self.rightView       = nil;
    self.animationView   = nil;
    
    [super dealloc];
}

#pragma mark - default

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
