//
//  SSControl.h
//  Video
//
//  Created by 于天航 on 12-9-6.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct SSEdgeInsets {
    CGFloat top, left;  // specify amount to inset (positive) for top & left the edges. values can be negative to 'outset'. bottom edge will be assigned to the opposite number of top edge, right edge will be assigned to the opposite number of left edge.
} SSEdgeInsets;

UIKIT_STATIC_INLINE SSEdgeInsets SSEdgeInsetsMake(CGFloat top, CGFloat left) {
    SSEdgeInsets insets = {top, left};
    return insets;
}

UIKIT_STATIC_INLINE CGRect SSEdgeInsetsInsetRect(CGRect rect, SSEdgeInsets insets) {
    rect.origin.x    += insets.left;
    rect.origin.y    += insets.top;
    return rect;
}

#define SSEdgeInsetsZero SSEdgeInsetsMake(0.f, 0.f)

typedef enum SSControlContentArrangement {
    SSControlContentArrangementHorizontal,
    SSControlContentArrangementVertical
} SSControlContentArrangement;

typedef enum SSControlContentHorizontalAligment {
    SSControlContentHorizontalAligmentLeft,
    SSControlContentHorizontalAligmentCenter,
    SSControlContentHorizontalAligmentRight
} SSControlContentHorizontalAligment;

typedef enum SSControlContentVerticalAligment {
    SSControlContentVerticalAligmentTop,
    SSControlContentVerticalAligmentCenter,
    SSControlContentVerticalAligmentBottom
} SSControlContentVerticalAligment;

@interface SSControl : NSObject

@end
