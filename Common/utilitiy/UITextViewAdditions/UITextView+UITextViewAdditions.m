//
//  UITextView+UITextViewAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-27.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "UITextView+UITextViewAdditions.h"

@implementation UITextView (UITextViewAdditions)

- (NSRange)markedRange
{
    NSUInteger markedStart = [self offsetFromPosition:self.beginningOfDocument toPosition:self.markedTextRange.start];
    NSUInteger markedEnd = [self offsetFromPosition:self.beginningOfDocument toPosition:self.markedTextRange.end];
    
    return NSMakeRange(markedStart, markedEnd - markedStart);
}
@end
