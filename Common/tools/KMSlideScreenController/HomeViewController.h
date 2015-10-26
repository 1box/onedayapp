//
//  HomeViewController.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-2.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

- (void)restoreViewLocation;
- (void)moveToLeftSide;
- (void)moveToRightSide;
- (void)animateHomeViewToSide:(CGRect)newViewRect;

- (IBAction)leftBarBtnTapped:(id)sender;
- (IBAction)rightBarBtnTapped:(id)sender;

@end
