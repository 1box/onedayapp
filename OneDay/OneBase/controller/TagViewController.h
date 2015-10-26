//
//  AddTagViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"

@class KMTableView;
@class DailyDoBase;

@interface TagViewController : KMViewControllerBase

@property (nonatomic) IBOutlet KMTableView *tagsView;
@property (nonatomic) DailyDoBase *dailyDo;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end
