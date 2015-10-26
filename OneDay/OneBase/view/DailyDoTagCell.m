//
//  TagPropertyCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoTagCell.h"
#import "DailyDoBase.h"
#import "TagData.h"
#import "TagTokenView.h"

@interface DailyDoTagCell ()
@property (nonatomic, retain) NSMutableArray *tagTokens;
@end

@implementation DailyDoTagCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    if (_dailyDo) {
        
        if (_tagTokens == nil) {
            self.tagTokens = [NSMutableArray arrayWithCapacity:[_dailyDo.tags count]];
        }
        else {
            for (TagTokenView *tagToken in _tagTokens) {
                [tagToken removeFromSuperview];
            }
            [_tagTokens removeAllObjects];
        }
        
        if ([_dailyDo.tags count] > 0) {
            self.nameLabel.hidden = YES;
            
            CGFloat subviewX = 48.f;
            CGFloat subviewY = 0.f;
            
            for (TagData *tag in _dailyDo.tags) {
                TagTokenView *tagToken = [[TagTokenView alloc] initWithTag:NSLocalizedString(tag.name, nil)];
                subviewY = (self.bounds.size.height - tagToken.frame.size.height)/2;
                tagToken.frame = CGRectMake(subviewX, subviewY, tagToken.frame.size.width, tagToken.frame.size.height);
                
                subviewX += tagToken.frame.size.width + 5.f;
                
                [self addSubview:tagToken];
                [_tagTokens addObject:tagToken];
            }
        }
        else {
            self.nameLabel.hidden = NO;
        }
    }
}

@end
