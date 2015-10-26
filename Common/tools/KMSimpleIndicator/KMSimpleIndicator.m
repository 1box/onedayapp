//
//  SSSimpleIndicator.m
//  BaseGallery
//
//  Created by Tianhang Yu on 12-2-10.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMSimpleIndicator.h"

#define MESSAGE_LABEL_WIDTH 200.f
#define MESSAGE_LABEL_HEIGHT 100.f

@implementation SimpleViewController

@synthesize msgLabel=_msgLabel;

- (void)hideSelf
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:2];
    
    _msgLabel.alpha = 0.f;
    
    [UIView commitAnimations];
}

- (void)showMessage:(NSString *)msg withY:(CGFloat)y
{
    CGRect selfBounds = self.view.bounds;
    _msgLabel.frame = CGRectMake((selfBounds.size.width - MESSAGE_LABEL_WIDTH) / 2, y, MESSAGE_LABEL_WIDTH, MESSAGE_LABEL_HEIGHT);
    
    _msgLabel.text = msg;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideSelf)];
    
    _msgLabel.alpha = 0.7;
    
    [UIView commitAnimations];
}

- (void)showMessage:(NSString *)msg withRect:(CGRect)aRect
{
    _msgLabel.frame = aRect;
    
    _msgLabel.text = msg;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideSelf)];
    
    _msgLabel.alpha = 0.7;
    
    [UIView commitAnimations];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.msgLabel = [[UILabel alloc] init];
    _msgLabel.text = @"blahblahblah";
    _msgLabel.alpha = 0.f;
    _msgLabel.textColor = [UIColor whiteColor];
    _msgLabel.backgroundColor = [UIColor blackColor];
    _msgLabel.font = FONT_DEFAULT(18.f);
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    _msgLabel.layer.cornerRadius = 5;
    
    [self.view addSubview:_msgLabel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end


@implementation KMSimpleIndicator

@synthesize rootVC=_rootVC;

static KMSimpleIndicator *_shareIndicator = nil;

+ (KMSimpleIndicator *)sharedIndicator
{
    @synchronized(self) {
        if (!_shareIndicator) {
            _shareIndicator = [[KMSimpleIndicator alloc] init];
        }
    }
    return _shareIndicator;
}

+ (id)alloc
{
    NSAssert(_shareIndicator == nil, @"Attemted to allocate asecond instance of a singleton");
    
    return [super alloc];
}

- (void)showMessage:(NSString *)msg withRect:(CGRect)aRect
{
    [_rootVC showMessage:msg withRect:aRect];
}

- (void)showMessage:(NSString *)msg withY:(CGFloat)y
{
    [_rootVC showMessage:msg withY:y];
}

- (id)init 
{
    self = [super init];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        [self setHidden:NO];
        self.backgroundColor = [UIColor clearColor];
        
        self.rootVC = [[SimpleViewController alloc] init];
        self.rootViewController = _rootVC;
    }
    return self;
}

@end
