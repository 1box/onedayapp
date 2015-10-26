//
//  UILabel+UILabelAdditions.m
//  Drawus
//
//  Created by Tianhang Yu on 12-4-2.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "UILabel+UILabelAdditions.h"

@implementation UILabel (UILabelAdditions)

- (void)heightThatFitsWidth:(CGFloat)fitWidth
{
    self.numberOfLines = 0.f;
    
    CGRect fitFrame = self.frame;
    CGFloat fitHeight = [self.text sizeWithFont:self.font
                              constrainedToSize:CGSizeMake(fitWidth, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping].height;
    
    fitFrame.size.width = fitWidth;
    fitFrame.size.height = fitHeight;
    
    self.frame = fitFrame;
}

@end
