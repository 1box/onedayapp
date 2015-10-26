//
//  InputViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-30.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"
#import "KMTextView.h"

@class DailyDoBase;

@interface TodoViewController : KMViewControllerBase

@property (nonatomic) IBOutlet KMTextView *inputView;
@property (nonatomic) IBOutlet UIToolbar *inputHelperBar;
@property (nonatomic) DailyDoBase *dailyDo;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end
