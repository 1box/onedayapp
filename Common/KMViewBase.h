//
//  KMViewBase.h
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMViewBase : UIView

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void)loadView;
- (void)viewDidAppear;
- (void)viewDidDisappear;
- (void)didReceiveMemoryWarning;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
@end
