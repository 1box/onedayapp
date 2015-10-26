//
//  KMNavigationBar.m
//  Drawus
//
//  Created by Tianhang Yu on 12-3-24.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "KMNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

@interface KMNavigationBar ()

@property (nonatomic, retain) CAGradientLayer *shadow;

@end

@implementation KMNavigationBar

@synthesize shadow=_shadow;

#pragma mark - default

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f].CGColor;
        CGColorRef lightColor = [UIColor clearColor].CGColor;  
        CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
        self.shadow = newShadow;
        newShadow.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 4);
        newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
        [self.layer addSublayer:newShadow];
        [newShadow release];
    }
    return self;
}

- (void)showShadow:(BOOL)show
{
    _shadow.hidden = !show;
}

- (void)dealloc
{
    self.shadow = nil;
    
    [super dealloc];
}

@end
