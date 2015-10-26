//
//  WorkoutAlarmCellView.m
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmCellView.h"
#import "AlarmData.h"
#import "KMModelManager.h"
#import "AlarmManager.h"
#import "KMDateUtils.h"


@interface AlarmCellView ()
@property (nonatomic) IBOutlet UILabel *AMPMLabel;
@property (nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) IBOutlet UILabel *nagTypeLabel;
@property (nonatomic) IBOutlet UILabel *repeatLabel;
@property (nonatomic) IBOutlet UILabel *noteLabel;
@property (nonatomic) IBOutlet UISwitch *openSwitch;
@end


@implementation AlarmCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setAlarm:(AlarmData *)alarm
{
    _alarm = alarm;
    if (_alarm) {
        NSString *timeA = [HourToMiniteAFormatter() stringFromDate:[HourToMiniteFormatter() dateFromString:_alarm.alarmTime]];
        _AMPMLabel.text = [timeA substringFromIndex:5];
        _timeLabel.text = [timeA substringToIndex:5];
        _nagTypeLabel.text = [_alarm nagTypeText];
        _repeatLabel.text = [_alarm repeatText];
        _noteLabel.text = _alarm.text;
        
        _openSwitch.on = [_alarm.open boolValue];
    }
}

- (IBAction)handleOpenSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    _alarm.open = [NSNumber numberWithBool:aSwitch.isOn];
    [[KMModelManager sharedManager] saveContext:nil];
    
    [[AlarmManager sharedManager] rebuildAlarmNotifications];
}

@end
