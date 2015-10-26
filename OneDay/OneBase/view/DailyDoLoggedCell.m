//
//  LoggedDoListCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoLoggedCell.h"
#import "DailyDoBase.h"
#import "KMDateUtils.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoPresentView.h"
#import "KMModelManager.h"
#import "UIView+CornerMark.h"

#define TopPadding 14.f
#define DateLabelRightMargin 7.f
#define CompleteLabelWidth 195.f
#define PresentViewWidth 255.f

@implementation DailyDoLoggedCell

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

- (void)refreshUI
{
    CornerMarkColorType color = CornerMarkColorTypeOrange;
    if ([[NSDate dateWithTimeIntervalSince1970:[_loggedDo.createTime doubleValue]] isTypicallyWorkday]) {
        color = CornerMarkColorTypeCyan;
    }
    UIImageView *markView = [self renderCornerMark:color scaleType:CornerMarkScaleTypeSmall isFavorite:NO];
    
//    CGFloat topMargin = 0.f;
//    if (self.locationType == KMTableViewCellLocationTypeAlone || self.locationType == KMTableViewCellLocationTypeTop) {
//        topMargin = 1.f;
//    }
    setFrameWithOrigin(markView, SSWidth(self) - SSWidth(markView), 0.f);
}

- (void)setLoggedDo:(DailyDoBase *)loggedDo
{
    _loggedDo = loggedDo;
    if (_loggedDo) {
        _checkbox.enabled = ![_loggedDo.check boolValue] && [_loggedDo.todos count] > 0;
        _dateLabel.text = [MonthToDayFormatter() stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_loggedDo.createTime doubleValue]]];
        _completeLabel.text = [_loggedDo completionText];
        _presentView.dailyDo = _loggedDo;
    }
}

#pragma mark - Actions

- (IBAction)checkbox:(id)sender
{
    if (![_loggedDo.check boolValue]) {
        for (TodoData *tTodo in _loggedDo.todos) {
            [tTodo setCheck:@YES];
        }
        [[KMModelManager sharedManager] saveContext:nil];
        
        _checkbox.enabled = NO;
        _completeLabel.text = [_loggedDo completionText];
        [self refreshUI];
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
