//
//  AlarmInputViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmInputViewController.h"
#import "AlarmData.h"

@interface AlarmInputViewController () <UITextFieldDelegate>
@end

@implementation AlarmInputViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _textField.text = _alarm.text;
    [_textField becomeFirstResponder];
}

- (IBAction)back:(id)sender
{
    _alarm.text = _textField.text;
    [_textField resignFirstResponder];
    [super back:sender];
}

@end
