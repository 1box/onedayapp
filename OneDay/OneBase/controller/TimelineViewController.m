//
//  DateViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-30.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TimelineViewController.h"
#import "MADayView.h"
#import "MAEvent.h"

#import "KMModelManager.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoBase.h"
#import "KMDateUtils.h"
#import "NSDate+NSDateAdditions.h"

#define kMAEventToDoUserInfoKey @"kMAEventToDoUserInfoKey"

@interface TimelineViewController () <MADayViewDataSource, MADayViewDelegate>
@property (nonatomic) NSArray *todos;
@property (nonatomic) TodoData *currentTodo;
@end

@implementation TimelineViewController

- (NSString *)pageNameForTrack
{
    if ([_dailyDos count] > 0) {
        DailyDoBase *dailyDo = [_dailyDos objectAtIndex:0];
        return [NSString stringWithFormat:@"TimelinePage_%@", dailyDo.addon.dailyDoName];
    }
    else {
        return [super pageNameForTrack];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _calendarView.autoScrollToFirstEvent = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_calendarView reloadData];
}

#pragma mark - private

- (DailyDoBase *)dailyDoAtDate:(NSDate *)date
{
    for (DailyDoBase *dailyDo in _dailyDos) {
        if ([[NSDate dateWithTimeIntervalSince1970:[dailyDo.createTime doubleValue]] isSameDayWithDate:date]) {
            return dailyDo;
        }
    }
    return nil;
}

- (void)showDatePicker
{
    _datePicker.date = [_currentTodo dateForStartTime];
    
    if (_pickerContainer.hidden) {
        _pickerContainer.hidden = NO;
        
        CGRect datePickerFrame = _pickerContainer.frame;
        datePickerFrame.origin.y = SSHeight(self.view) - datePickerFrame.size.height;
        CGFloat duration = 0.25f;
        
        CGRect tmpFrame = _calendarView.frame;
        tmpFrame.size.height -= datePickerFrame.size.height;
        
        [UIView animateWithDuration:duration animations:^{
            _pickerContainer.frame = datePickerFrame;
        } completion:^(BOOL finished) {
            _calendarView.frame = tmpFrame;
        }];
    }
}

- (void)hideDatePicker
{
    if (!_pickerContainer.hidden) {
        
        CGRect datePickerFrame = _pickerContainer.frame;
        datePickerFrame.origin.y = SSHeight(self.view);
        CGFloat duration = 0.2f;
        
        CGRect tmpFrame = _calendarView.frame;
        tmpFrame.size.height += datePickerFrame.size.height;
        
        [UIView animateWithDuration:duration animations:^{
            _pickerContainer.frame = datePickerFrame;
            _calendarView.frame = tmpFrame;
        } completion:^(BOOL finished) {
            _pickerContainer.hidden = YES;
        }];
    }
}

#pragma mark - Actions

- (IBAction)pickerCanceled:(id)sender
{
    [self hideDatePicker];
}

- (IBAction)pickerConfirmed:(id)sender
{
    [self hideDatePicker];
    
    _currentTodo.startTime = [[TodoData startTimeDateFormmatter] stringFromDate:_datePicker.date];
    [[KMModelManager sharedManager] saveContext:nil];
    
    [_calendarView reloadData];
}

#pragma mark - MADayViewDataSource

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date
{
	NSMutableArray *events = [NSMutableArray array];
	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit |
                                                                             NSMonthCalendarUnit |
                                                                             NSWeekdayCalendarUnit |
                                                                             NSDayCalendarUnit)
																   fromDate:date];
    [components setTimeZone:[NSTimeZone localTimeZone]];
	[components setSecond:0];
    
    DailyDoBase *dailyDo = [self dailyDoAtDate:date];
    if (dailyDo) {
        self.todos = [dailyDo todosSortedByStartTime];
    }
    else {
        self.todos = nil;
    }
    
    BOOL flag = NO;
    for (TodoData *todo in _todos) {
        NSDate *tmpDate = [todo dateForStartTime];
       
        if (tmpDate) {
            MAEvent *event = [[MAEvent alloc] init];
            
            event.title = [NSString stringWithFormat:@"%@", [todo timelineContent]];
            event.userInfo = [NSDictionary dictionaryWithObject:todo forKey:kMAEventToDoUserInfoKey];
            
            event.textColor = [UIColor whiteColor];
            event.backgroundColor = (flag = !flag) ? [UIColor purpleColor] : [UIColor brownColor];
            
            NSDateComponents *tmpComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:tmpDate];
            [components setHour:tmpComponents.hour];
            [components setMinute:tmpComponents.minute];
            
            event.start = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            tmpDate = [NSDate dateWithTimeInterval:[todo.duration intValue] sinceDate:tmpDate];
            tmpComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:tmpDate];
            [components setHour:tmpComponents.hour];
            [components setMinute:tmpComponents.minute];
            
            event.end = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            [events addObject:event];
        }
    }
	
//	// create an all day event
//	MAEvent *event = [[MAEvent alloc] init];
//	event.allDayEvent = YES;
//	event.eventName = @"All Day Event";
//	[events addObject:event];
//	[event release];
	
	return events;
}

#pragma mark - MADayViewDelegate

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event
{
    self.currentTodo = [event.userInfo objectForKey:kMAEventToDoUserInfoKey];
    [self showDatePicker];
}

@end
