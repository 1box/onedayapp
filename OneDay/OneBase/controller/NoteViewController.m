//
//  NoteViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NoteViewController.h"
#import "DailyDoBase.h"
#import "AddonData.h"
#import "KMModelManager.h"
#import "DailyDoManager.h"

@interface NoteViewController ()
@end

@implementation NoteViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"NotePage_%@", _dailyDo.addon.dailyDoName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshText];
    [_textView becomeFirstResponder];
}

#pragma mark - private

- (void)refreshText
{
    _textView.text = [_dailyDo valueForKey:_propertyKey];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    [_dailyDo setValue:_textView.text forKey:_propertyKey];
    [[KMModelManager sharedManager] saveContext:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
