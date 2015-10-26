//
//  AddonListCellBase.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoTodayCell.h"
#import "DailyDoBase.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoManager.h"
#import "KMDateUtils.h"
#import "DailyDoDateView.h"
#import "DailyDoPresentView.h"

#define LeftPadding 5.f
#define RightPadding 5.f
#define DateViewWidth 255.f
#define PresentViewWidth 255.f
#define DateViewBottomMargin 7.f

@interface DailyDoTodayCell ()
@end

@implementation DailyDoTodayCell

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfold:(BOOL)unfold
{
    CGFloat ret = 0.f;
    ret += [DailyDoDateView heightForDailyDo:dailyDo fixWidth:DateViewWidth];
    if (!unfold) {
        CGFloat presentHeight = [DailyDoPresentView heightOfCellForDailyDo:dailyDo];
        if (presentHeight > 0) {
            ret += presentHeight + DateViewBottomMargin;
        }
    }
    return ret;
}

#pragma mark - setter&getter

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    
    if (_dailyDo) {
        
        _checkbox.selected = [_dailyDo.check boolValue];
        _dateView.dailyDo = _dailyDo;
        _presentView.dailyDo = _dailyDo;
    }
}

#pragma mark - extended

- (void)setUnfolded:(BOOL)unfolded
{
    [super setUnfolded:unfolded];
    _presentView.hidden = self.isUnfolded;
    if (!_presentView.hidden) {
        [_presentView refreshUI];
    }
}

- (NSArray *)unfoldConstraints
{
    NSMutableArray *mutFoldConstraints = [NSMutableArray arrayWithCapacity:20];
    
    CGFloat dateHeight = [DailyDoDateView heightForDailyDo:_dailyDo fixWidth:DateViewWidth];
    NSDictionary *views = NSDictionaryOfVariableBindings(_dateView, _checkbox);
    NSDictionary *metrics = @{@"dateHeight" : @(dateHeight)};
    
    NSString *format = @"V:|[_dateView]|";
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [mutFoldConstraints addObjectsFromArray:verticalConstraints];
    
    format = @"V:|-5.0-[_checkbox(33.0)]";
    verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views];
    [mutFoldConstraints addObjectsFromArray:verticalConstraints];
    
    metrics = @{@"leftPadding" : @(LeftPadding), @"rightPadding" : @(RightPadding)};
    format = @"H:|-leftPadding-[_checkbox(33.0)]-leftPadding-[_dateView]-rightPadding-|";
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:views];
    [mutFoldConstraints addObjectsFromArray:horizontalConstraints];
    
    return [mutFoldConstraints copy];
}

- (NSArray *)foldConstraints
{
    NSMutableArray *mutUnfoldConstraints = [NSMutableArray arrayWithCapacity:20];
    
    CGFloat dateHeight = [DailyDoDateView heightForDailyDo:_dailyDo fixWidth:DateViewWidth];
    CGFloat presentHeight = [DailyDoPresentView heightOfCellForDailyDo:_dailyDo] + 10.f;    // add 10 to fix bug
    CGFloat dateViewBottomMargin = presentHeight > 0 ? DateViewBottomMargin : 0;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_dateView, _presentView, _checkbox);
    NSDictionary *metrics = @{@"margin" : @(dateViewBottomMargin),
                              @"presentHeight" : @(presentHeight),
                              @"dateHeight" : @(dateHeight),
                              @"dateBottom" : @(dateViewBottomMargin + presentHeight)};
    
    NSString *format = @"V:|[_dateView]-margin-[_presentView(presentHeight)]|";
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [mutUnfoldConstraints addObjectsFromArray:verticalConstraints];
    
    format = @"V:|-5.0-[_checkbox(33.0)]";
    verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views];
    [mutUnfoldConstraints addObjectsFromArray:verticalConstraints];
    
    metrics = @{@"leftPadding" : @(LeftPadding), @"rightPadding" : @(RightPadding)};
    format = @"H:|-leftPadding-[_checkbox(33.0)]-leftPadding-[_dateView]-rightPadding-|";
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:views];
    [mutUnfoldConstraints addObjectsFromArray:horizontalConstraints];
    
    format = @"H:|-leftPadding-[_checkbox(33.0)]-leftPadding-[_presentView]-rightPadding-|";
    horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                   options:0
                                                                   metrics:metrics
                                                                     views:views];
    [mutUnfoldConstraints addObjectsFromArray:horizontalConstraints];
    
    return [mutUnfoldConstraints copy];
}

@end
