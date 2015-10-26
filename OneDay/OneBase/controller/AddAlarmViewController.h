//
//  AddAlarmViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AddonData;
@class AlarmData;
@class KMTableView;

@interface AddAlarmViewController : KMViewControllerBase

@property (nonatomic) IBOutlet KMTableView *listView;
@property (nonatomic) IBOutlet UIDatePicker *timePicker;
@property (nonatomic) IBOutlet UISwitch *nagTypeSwitch;

@property (nonatomic) AddonData *addon;
@property (nonatomic) AlarmData *alarm;

- (IBAction)saveAndDismiss:(id)sender;
- (IBAction)saveAndBack:(id)sender;
- (IBAction)switchNagType:(id)sender;
@end
