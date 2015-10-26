//
//  UILabel+UILabelAdditions.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-2.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline CGFloat widthOfContent (NSString *contentStr, CGFloat fontSize) {
    CGFloat textWidth = 0.f;
    
    if ([contentStr length] > 0) {
        textWidth = [contentStr length]*fontSize;
    }
    
    return textWidth;
}

static inline CGFloat heightOfContent (NSString *contentStr, CGFloat fixWidth, CGFloat fontSize) {
    
    CGFloat textHeight = 0;
    
    if ([contentStr length] > 0) {
        CGSize size = [contentStr sizeWithFont:[UIFont systemFontOfSize:fontSize]
                             constrainedToSize:CGSizeMake(fixWidth, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        textHeight = size.height;
    }
    
    return textHeight;
}

@interface UILabel (UILabelAdditions)

// only for not autolayout
- (void)heightThatFitsWidth:(CGFloat)fitWidth;

@end
