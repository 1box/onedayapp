//
//  PopViewController.m
//  Drawus
//
//  Created by Tianhang Yu on 12-4-1.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMPopViewController.h"

#define animation_background_disappear  @"background_disappear"
#define animation_background_appear     @"background_appear"

@interface PopCloseButton : UIButton

@end

@implementation PopCloseButton

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect subRect = CGRectMake((rect.size.width - 30.f) / 2, (rect.size.height - 30.f) / 2, 30.f, 30.f);
    drawCloseButton(context, subRect, [UIColor whiteColor], [UIColor redColor]);
}

@end

@interface KMPopViewController () {
    
    BOOL _closabled;
}

@property (nonatomic, retain) UILabel        *bgLabel;
@property (nonatomic, retain) PopCloseButton *closeBtn;

@end

@implementation KMPopViewController

@synthesize kmDelegate =_kmDelegate;
@synthesize bgLabel    =_bgLabel;
@synthesize closeBtn   =_closeBtn;

#pragma mark - private

- (void)hide
{
    CABasicAnimation *boundSmallAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	boundSmallAnimation.removedOnCompletion = YES;
	boundSmallAnimation.duration = 0.3;
	boundSmallAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0,1.0,1)];
	boundSmallAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3,1.3,1)];
	[self.view.layer addAnimation:boundSmallAnimation forKey:@"scaleSmall"];
	
	[UIView beginAnimations:animation_background_disappear context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.view.alpha = 0.0;
	
	[UIView commitAnimations];
}

- (void)closeBtnClicked:(id)sender
{
    [self hide];
}

#pragma mark - public

- (void)pop
{
    CABasicAnimation *boundBigAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	boundBigAnimation.removedOnCompletion = YES;
	boundBigAnimation.duration = 0.3;
	boundBigAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2,0.2,1)];
	boundBigAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1,1.1,1)];
	[self.view.layer addAnimation:boundBigAnimation forKey:@"scaleBig"];
    
	[UIView beginAnimations:animation_background_appear context:nil];
    [UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
	self.view.alpha = 1;
    
	[UIView commitAnimations];
}

- (void)setClosable:(BOOL)closable
{
    _closabled = !closable;
    _closeBtn.hidden = _closabled;
}

- (void)setCloseBtnFrame:(CGRect)cFrame
{
    _closeBtn.frame = cFrame;
    
    [self.view bringSubviewToFront:_closeBtn];
}

#pragma mark - UIAnimationSelector

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:animation_background_appear])
	{
        
	}
	else if ([animationID isEqualToString:animation_background_disappear])
	{
        if (_kmDelegate != nil)
        {
            if ([_kmDelegate respondsToSelector:@selector(didHidePopViewController:)])
            {
                [_kmDelegate didHidePopViewController:self];
            }
        }
	}
	
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    CGRect vFrame = self.view.bounds;
    
    self.bgLabel = [[[UILabel alloc] initWithFrame:vFrame] autorelease];
    _bgLabel.backgroundColor = [UIColor blackColor];
    _bgLabel.alpha = 0.7;
    [self.view addSubview:_bgLabel];

    CGRect cFrame = CLOSE_BUTTON_FRAME;

    self.closeBtn = [PopCloseButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.frame = cFrame;
    _closeBtn.backgroundColor = [UIColor clearColor];
    _closeBtn.hidden = _closabled;
    [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
}

- (void)dealloc
{
    self.bgLabel = nil;
    self.closeBtn = nil;

    [super dealloc];
}

#pragma mark - default

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
