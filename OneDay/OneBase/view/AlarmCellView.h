//
//  WorkoutAlarmCellView.h
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMUnfoldTableCell.h"

@class AlarmData;

@interface AlarmCellView : KMUnfoldTableCell
@property (nonatomic) AlarmData *alarm;
- (IBAction)handleOpenSwitch:(id)sender;
@end
