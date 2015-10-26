//
//  DailyDoTomorrowCell.m
//  OneDay
//
//  Created by Yu Tianhang on 13-2-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyDoTomorrowCell.h"
#import "DailyDoBase.h"
#import "KMDateUtils.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoPresentView.h"

#define TopPadding 14.f
#define DateLabelRightMargin 7.f
#define CompleteLabelWidth 195.f
#define PresentViewWidth 255.f

@implementation DailyDoTomorrowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfolded:(BOOL)unfolded
{
    CGFloat completeHeight = heightOfContent(dailyDo.completionText, CompleteLabelWidth, 13.f);
    CGFloat ret = TopPadding*2 + completeHeight;
    if (unfolded) {
        ret += [DailyDoPresentView heightOfCellForDailyDo:dailyDo];
    }
    return ret;
}

- (void)setTomorrowDo:(DailyDoBase *)tomorrowDo
{
    _tomorrowDo = tomorrowDo;
    if (_tomorrowDo) {
        _dateLabel.text = [MonthToDayFormatter() stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_tomorrowDo.createTime doubleValue]]];
        _tomorrowDoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_tomorrowDoText", nil), [_tomorrowDo.todos count]];
        _presentView.dailyDo = _tomorrowDo;
    }
}

#pragma mark - extended

- (void)setUnfolded:(BOOL)unfolded
{
    _unfolded = unfolded;
    
    _presentView.hidden = !self.isUnfolded;
    if (!_presentView.hidden) {
        [_presentView refreshUI];
    }
}

@end
