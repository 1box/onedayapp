//
//  MainViewController.m
//  Drawus
//
//  Created by Tianhang Yu on 12-3-21.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "DailyDoViewController.h"
#import "AddonData.h"
#import "DailyDoView.h"
#import "HintHelper.h"

@interface DailyDoViewController ()
@property (nonatomic) HintHelper *hint;
@end

@implementation DailyDoViewController

- (void)didReceiveMemoryWarning
{
    [_dailyDoView didReceiveMemoryWarning];
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [_dailyDoView prepareForSegue:segue sender:sender];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        if (!_hint.shown) {
            if (hasHintForKey(@"DailyDo")) {
                resetHasHintForKey(@"DailyDo");
            }
            
            self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:@"DailyDo"];
            [_hint show];
            [KMCommon playSound:@"shake.mp3"];
        }
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

- (NSString *)pageNameForTrack
{
    NSString *pageName = @"DailyDo";
    if (_addon) {
        pageName = _addon.dailyDoName;
    }
    return pageName;
}

#pragma mark - Viewlifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(_addon.dailyDoName, nil);
    
    [_dailyDoView setAddon:_addon];
    [_dailyDoView loadView];
    
    self.hint = [[HintHelper alloc] initWithViewController:self dialogsPathPrefix:@"DailyDo"];
    [_hint show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_dailyDoView viewDidAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_dailyDoView viewDidDisappear];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_dailyDoView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
