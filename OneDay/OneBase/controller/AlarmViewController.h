//
//  WorkoutAlarmViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AddonData;

@interface AlarmViewController : KMViewControllerBase

@property (nonatomic) AddonData *addon;

- (IBAction)edit:(id)sender;
- (IBAction)closeAll:(id)sender;
- (IBAction)autoAddToDailyDo:(id)sender;

@end
