//
//  HomeViewController.m
//  Drawus
//
//  Created by Tianhang Yu on 12-4-2.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"

#define kTriggerOffSet 100.0f

@interface HomeViewController () {

    CGPoint touchBeganPoint;
    BOOL homeViewIsOutOfStage;
}

@end

@implementation HomeViewController

#pragma mark - UITouch

// Check touch position in this method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchBeganPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
}

// Scale or move select view when touch moved
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    CGFloat xOffSet = touchPoint.x - touchBeganPoint.x;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (xOffSet < 0) {
        [appDelegate makeRightViewVisible];
    }
    else if (xOffSet > 0) {
        [appDelegate makeLeftViewVisible];
    }
    
    self.navigationController.view.frame = CGRectMake(xOffSet, 
                                                      self.navigationController.view.frame.origin.y, 
                                                      self.navigationController.view.frame.size.width, 
                                                      self.navigationController.view.frame.size.height);
}

// reset indicators when touch ended
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // animate to left side
    if (self.navigationController.view.frame.origin.x < -kTriggerOffSet) 
        [self moveToLeftSide];
    // animate to right side
    else if (self.navigationController.view.frame.origin.x > kTriggerOffSet) 
        [self moveToRightSide];
    // reset
    else 
        [self restoreViewLocation];
}

#pragma mark - move methods

// restore view location
- (void)restoreViewLocation 
{
    homeViewIsOutOfStage = NO;
    [UIView animateWithDuration:0.3 
                     animations:^{
                         self.navigationController.view.frame = CGRectMake(0, 
                                                                           self.navigationController.view.frame.origin.y, 
                                                                           self.navigationController.view.frame.size.width, 
                                                                           self.navigationController.view.frame.size.height);
                     } 
                     completion:^(BOOL finished){
                         UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10030];
                         [overView removeFromSuperview];
                     }];
}

// move view to left side
- (void)moveToLeftSide 
{
    homeViewIsOutOfStage = YES;
    [self animateHomeViewToSide:CGRectMake(-290.0f, 
                                           self.navigationController.view.frame.origin.y, 
                                           self.navigationController.view.frame.size.width, 
                                           self.navigationController.view.frame.size.height)];
}

// move view to right side
- (void)moveToRightSide
{
    homeViewIsOutOfStage = YES;
    [self animateHomeViewToSide:CGRectMake(290.0f, 
                                           self.navigationController.view.frame.origin.y, 
                                           self.navigationController.view.frame.size.width, 
                                           self.navigationController.view.frame.size.height)];
}

// animate home view to side rect
- (void)animateHomeViewToSide:(CGRect)newViewRect
{
    [UIView animateWithDuration:0.2 
                     animations:^{
                         self.navigationController.view.frame = newViewRect;
                     } 
                     completion:^(BOOL finished){
                         UIControl *overView = [[UIControl alloc] init];
                         overView.tag = 10001;
                         overView.backgroundColor = [UIColor clearColor];
                         overView.frame = self.navigationController.view.frame;
                         [overView addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
                         [[[UIApplication sharedApplication] keyWindow] addSubview:overView];
                         [overView release];
                     }];
}

#pragma mark - actions

// handle left bar btn
- (IBAction)leftBarBtnTapped:(id)sender
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] makeLeftViewVisible];
    [self moveToRightSide];
}

// handle right bar btn
- (IBAction)rightBarBtnTapped:(id)sender
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] makeRightViewVisible];
    [self moveToLeftSide];
}

#pragma mark - default

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
