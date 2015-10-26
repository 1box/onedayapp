//
//  RootVerticalToolbar.m
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "RootVerticalToolbar.h"

@interface RootVerticalToolbar () {
    int _pageNumber;
}
@end

@implementation RootVerticalToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageNumber = 0;
    }
    return self;
}

#pragma mark - Actions

- (void)updatePageNumber
{
    _pageLabel.text = [NSString stringWithFormat:@"%d", _pageNumber];
}

- (void)spinPageViewWithNumber:(int)number
{
    if (_pageNumber != number) {
        UIViewAnimationTransition transition = UIViewAnimationTransitionNone;
        
        if (_pageNumber > number) {
            transition = UIViewAnimationTransitionFlipFromLeft;
        }
        else {
            transition = UIViewAnimationTransitionFlipFromRight;
        }
        
        _pageNumber = number;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:1.f];
        [UIView setAnimationTransition:transition forView:_pageView cache:YES];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(updatePageNumber)];
        
        [UIView commitAnimations];
    }
}
@end
