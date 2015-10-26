//
//  TagTokenView.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TagTokenView.h"

@interface TagTokenView ()
@property (nonatomic) UIImageView *backgroundView;
@property (nonatomic) UILabel *tagLabel;
@end

@implementation TagTokenView

- (id)initWithTag:(NSString *)tag
{
    self = [super init];
    if (self) {
        UIImage *tagTokenImage = [UIImage imageNamed:@"tag_token"];
        tagTokenImage = [tagTokenImage stretchableImageWithLeftCapWidth:tagTokenImage.size.width/2 topCapHeight:tagTokenImage.size.height/2];
        self.backgroundView = [[UIImageView alloc] initWithImage:tagTokenImage];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backgroundView];
        
        self.tagLabel = [[UILabel alloc] init];
        _tagLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.text = tag;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.font = [UIFont systemFontOfSize:10.f];
        [self addSubview:_tagLabel];
        
        [_tagLabel sizeToFit];
        
        CGRect tmpFrame = self.frame;
        tmpFrame.size.height = 22.f;
        tmpFrame.size.width = MAX(_tagLabel.frame.size.width + 10, 23.f);
        self.frame = tmpFrame;
        _backgroundView.frame = self.bounds;
        
        _tagLabel.center = CGPointMake(tmpFrame.size.width/2, tmpFrame.size.height/2);
    }
    return self;
}

@end
