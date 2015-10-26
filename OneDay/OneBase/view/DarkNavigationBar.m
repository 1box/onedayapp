//
//  DarkNavigationBar.m
//  OneDay
//
//  Created by Kimimaro on 13-4-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DarkNavigationBar.h"

@implementation DarkNavigationBar

- (void)awakeFromNib
{
    NSString *imageName = [[KMCommon OSVersion] floatValue] < 7.f ? @"dark_nav_bg_pre.png" : @"dark_nav_bg.png";
    UIImage *navImage = [UIImage imageNamed:imageName];
    navImage = [navImage stretchableImageWithLeftCapWidth:navImage.size.width/2 topCapHeight:navImage.size.height/2];
    [self setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    self.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
}

@end
