//
//  NavigationBarButton.m
//  OneDay
//
//  Created by Kimimaro on 13-4-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "NavigationBarButton.h"

#define NavigationButtonFixEdge 9.f

@implementation NavigationBarButton

- (void)awakeFromNib
{
    [self updateThemes];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self updateThemes];
    }
    return self;
}

#pragma mark - public

- (void)updateThemes
{
    self.titleLabel.font = [UIFont systemFontOfSize:16.f];
}

#pragma mark - extended

- (BOOL)isLeftNavBarButton
{
    return SSMinX(self) < ([KMCommon isPadDevice] ? 768.f/2 : 320.f/2);
}

- (UIEdgeInsets)alignmentRectInsets
{
    UIEdgeInsets ret = UIEdgeInsetsZero;
    if ([KMCommon OSVersion].floatValue >= 7.f) {
        if ([self isLeftNavBarButton]) {
            ret = UIEdgeInsetsMake(0, NavigationButtonFixEdge, 0, 0);
        }
        else {
            ret = UIEdgeInsetsMake(0, 0, 0, NavigationButtonFixEdge);
        }
    }
    return ret;
}

//- (UIEdgeInsets)contentEdgeInsets
//{
//    UIEdgeInsets ret = UIEdgeInsetsZero;
//    if ([KMCommon OSVersion].floatValue >= 7.f) {
//        if ([self isLeftNavBarButton]) {
//            ret = UIEdgeInsetsMake(0, -NavigationButtonFixEdge, 0, 0);
//        }
//        else {
//            ret = UIEdgeInsetsMake(0, 0, 0, -NavigationButtonFixEdge);
//        }
//    }
//    return ret;
//}

@end
