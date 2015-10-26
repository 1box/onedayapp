//
//  KMNavigationController.h
//  Drawus
//
//  Created by Tianhang Yu on 12-3-24.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMNavigationBar.h"

#define WINDOW_FRAME           CGRectMake(0.f, 0.f, 320.f, 460.f)
#define VIEW_CONTROLLERS_FRAME CGRectMake(0.f, 0.f, 320.f, 416.f)

#define NOTHING @"nothing"	// fix Syntax Hightlighting in Sublime!

@interface KMNavigationController : UINavigationController

@property (nonatomic, retain) KMNavigationBar *kmNavigationBar;

@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) UIView *leftView;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, retain) UIView *animationView;	// view for animation

@end
