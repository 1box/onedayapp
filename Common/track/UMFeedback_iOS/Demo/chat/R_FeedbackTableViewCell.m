//
//  R_FeedbackTableViewCell.m
//  UMeng Analysis
//
//  Created by liuyu on 9/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "R_FeedbackTableViewCell.h"

@implementation R_FeedbackTableViewCell

- (CGSize)stringCGSize:(NSString *)content font:(UIFont *)font width:(CGFloat)width {
    return [content sizeWithFont:font
               constrainedToSize:CGSizeMake(width, INT_MAX)
                   lineBreakMode:NSLineBreakByWordWrapping
    ];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentLeft;

//        CGRect textLabelFrame = self.textLabel.frame;
//        textLabelFrame.size.width = self.bounds.size.width - 50;
//        self.textLabel.frame = textLabelFrame;

        messageBackgroundView = [[UIImageView alloc] initWithFrame:self.textLabel.frame];
        messageBackgroundView.image = [[UIImage imageNamed:@"messages_right_bubble"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [self.contentView insertSubview:messageBackgroundView belowSubview:self.textLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [self stringCGSize:self.textLabel.text font:[UIFont systemFontOfSize:14.0] width:BubbleMaxWidth];

    CGRect textLabelFrame = CGRectMake(self.bounds.size.width - size.width - RightMargin, self.bounds.origin.y + 20, size.width, size.height);
    self.textLabel.frame = textLabelFrame;
    
    messageBackgroundView.frame = CGRectMake(textLabelFrame.origin.x - BubblePaddingLeft, textLabelFrame.origin.y - BubblePaddingTop, size.width + BubbleMarginHorizontal, size.height + BubbleMarginVertical);
}

@end
