//
//  FeedbackTableViewCell.m
//  UMeng Analysis
//
//  Created by liuyu on 9/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "L_FeedbackTableViewCell.h"
@implementation L_FeedbackTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        messageBackgroundView = [[UIImageView alloc] initWithFrame:self.textLabel.frame];
        messageBackgroundView.image = [[UIImage imageNamed:@"messages_left_bubble"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [self.contentView insertSubview:messageBackgroundView belowSubview:self.textLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = 25;
    textLabelFrame.size.width = 250;
    
    CGSize labelSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]
                           constrainedToSize:CGSizeMake(250.0f, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    textLabelFrame.size.height = labelSize.height + 6;
    self.textLabel.frame = textLabelFrame;
    
    messageBackgroundView.frame = CGRectMake(10, textLabelFrame.origin.y - 2, labelSize.width + 30, labelSize.height + 12);;
}

@end
