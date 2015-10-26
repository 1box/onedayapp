//
//  UIView+CornerMark.h
//  OneDay
//
//  Created by Kimimaro on 13-6-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CornerMarkColorType) {
    CornerMarkColorTypeBlue = 0,
    CornerMarkColorTypeCyan,
    CornerMarkColorTypeGreen,
    CornerMarkColorTypeOrange,
    CornerMarkColorTypePurple,
    CornerMarkColorTypeYellow
};

typedef NS_ENUM(NSInteger, CornerMarkScaleType) {
    CornerMarkScaleTypeSmall,
    CornerMarkScaleTypeNormal,
    CornerMarkScaleTypeLarget
};

@interface UIView (CornerMark)
- (UIImageView *)renderCornerMark:(CornerMarkColorType)color scaleType:(CornerMarkScaleType)scale isFavorite:(BOOL)favorite;
@end
