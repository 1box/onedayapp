//
//  ViewController.m
//  Demo
//
//  Created by iOS@Umeng on 9/27/12.
//  Copyright (c) 2012 iOS@Umeng. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "FeedbackViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize umFeedback = _umFeedback;


- (void)viewDidLoad
{
    [super viewDidLoad];
    _umFeedback = [UMFeedback sharedInstance];
    [_umFeedback setAppkey:UMENG_APPKEY delegate:self];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (IBAction)nativeFeedback:(id)sender {
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)webFeedback:(id)sender {
    [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY];
//    [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY dictionary:[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:@"hello"]];
}

- (IBAction)checkNewReplies:(id)sender {
    [_contentField resignFirstResponder];
    [UMFeedback checkWithAppkey:UMENG_APPKEY];
}



-(IBAction)editingEnded:(id)sender{
   [sender resignFirstResponder];
}

- (void)dealloc {
    _umFeedback.delegate = nil;
}


@end
