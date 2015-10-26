//
//  SmarkTipViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-12-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"

@class AddonData;

@interface TipViewController : KMViewControllerBase

@property (nonatomic) AddonData *currentAddon;

- (IBAction)pageControlClicked:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)dismiss:(id)sender;
@end
