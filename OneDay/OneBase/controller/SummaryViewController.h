//
//  SummaryViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-13.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

typedef NS_ENUM(NSInteger, SummaryViewType) {
    SummaryViewTypeMonth,
    SummaryViewTypeYear
};


@class AddonData;

@interface SummaryViewController : KMViewControllerBase

@property (nonatomic) SummaryViewType type;
@property (nonatomic) AddonData *addon;

- (IBAction)dismiss:(id)sender;

@end
