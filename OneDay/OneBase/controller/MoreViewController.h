//
//  MoreViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"

@class KMTableView;

@interface MoreViewController : KMViewControllerBase

@property (nonatomic) IBOutlet UIView *pickerContainer;
@property (nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (nonatomic) IBOutlet KMTableView *listView;
@property (nonatomic) IBOutlet UISwitch *randomCartoonSwitch;
@property (nonatomic) IBOutlet UISwitch *alarmSwitch;
@property (nonatomic) IBOutlet UISwitch *alarmSoundSwitch;
@property (nonatomic) IBOutlet UISwitch *alarmBadgeSwitch;
@property (nonatomic) IBOutlet UIDatePicker *alarmTimePicker;

- (IBAction)randomCartoonSwitch:(id)sender;
- (IBAction)alarmSwitch:(id)sender;
- (IBAction)alarmSoundSwitch:(id)sender;
- (IBAction)alarmBadgeSwitch:(id)sender;
- (IBAction)pickerCanceled:(id)sender;
- (IBAction)pickerConfirmed:(id)sender;
@end
