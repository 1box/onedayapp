//
//  DateViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-30.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"

@class MADayView;
@class DailyDoBase;

@interface TimelineViewController : KMViewControllerBase

@property (nonatomic) IBOutlet MADayView *calendarView;
@property (nonatomic) IBOutlet UIView *pickerContainer;
@property (nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) NSArray *dailyDos;

- (IBAction)pickerCanceled:(id)sender;
- (IBAction)pickerConfirmed:(id)sender;
@end
