//
//  UIView+CornerMark.m
//  OneDay
//
//  Created by Kimimaro on 13-6-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "UIView+CornerMark.h"

#define CornerMarkViewTag 10001

@implementation UIView (CornerMark)

- (UIImageView *)renderCornerMark:(CornerMarkColorType)color scaleType:(CornerMarkScaleType)scale isFavorite:(BOOL)favorite
{
    NSString *colorName = @"";
    switch (color) {
        case CornerMarkColorTypeBlue:
            colorName = @"blue";
            break;
        case CornerMarkColorTypeCyan:
            colorName = @"cyan";
            break;
        case CornerMarkColorTypeGreen:
            colorName = @"green";
            break;
        case CornerMarkColorTypeOrange:
            colorName = @"orange";
            break;
        case CornerMarkColorTypePurple:
            colorName = @"purple";
            break;
        case CornerMarkColorTypeYellow:
            colorName = @"yellow";
            break;
            
        default:
            break;
    }
    
    NSString *scaleName = @"";
    switch (scale) {
        case CornerMarkScaleTypeSmall:
            scaleName = @"small";
            break;
        case CornerMarkScaleTypeNormal:
            scaleName = @"";
            break;
        case CornerMarkScaleTypeLarget:
            scaleName = @"large";
            break;
            
        default:
            break;
    }
    
    if (!KMEmptyString(colorName)) {
        NSMutableString *imageName = [NSMutableString stringWithString:@"corner_mark"];
        if (!KMEmptyString(scaleName)) {
            [imageName appendFormat:@"_%@", scaleName];
        }
        if (favorite) {
            [imageName appendString:@"_favorite"];
        }
        [imageName appendFormat:@"_%@", colorName];
        [imageName appendString:@".png"];
        
        UIImageView *markView = (UIImageView *)[self viewWithTag:CornerMarkViewTag];
        if (!markView) {
            markView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[imageName copy]]];
            markView.tag = CornerMarkViewTag;
            [self addSubview:markView];
        }
        else {
            markView.image = [UIImage imageNamed:[imageName copy]];
        }
        
        setFrameWithOrigin(markView, SSWidth(self) - SSWidth(markView), 0);
        [self bringSubviewToFront:markView];
        
        return markView;
    }
    
    return nil;
}

@end
