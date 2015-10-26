//
//  DailyDoPresentView.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoPresentView.h"
#import "DailyDoManager.h"
#import "DailyDoBase.h"
#import "TagData.h"
#import "TagTokenView.h"

#define TagBlockHeight 44.f
#define SelfWidth 255.f
#define TextViewTextFontSize 14.f
#define BottomPadding 10.f


@interface DailyDoPresentView ()
@property (nonatomic) NSMutableArray *tagTokens;
@end


@implementation DailyDoPresentView

#pragma mark - public

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo
{
    NSString *todoText = [dailyDo presentedText];
    CGFloat height = heightOfContent(todoText, SelfWidth, TextViewTextFontSize);
    CGFloat ret = height;
    if ([dailyDo.tags count] > 0) {
        ret += TagBlockHeight;
    }
    else if (height > 0) {
        ret += BottomPadding;
    }
    return ret;
}

- (void)refreshUI
{
    [self removeConstraints:self.constraints];
    
    NSMutableArray *tConstraints = [NSMutableArray arrayWithCapacity:20];
    
    CGFloat textBottom = BottomPadding;
    if ([_dailyDo.tags count] > 0) {
        textBottom = TagBlockHeight;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_textView);
    NSDictionary *metrics = @{@"textBottom" : @(textBottom)};
    NSString *format = @"V:|[_textView]-textBottom-|";
    [tConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:views]];
    
    format = @"H:|[_textView]|";
    [tConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:views]];
    
    
    if ([_dailyDo.tags count] > 0) {
        NSMutableDictionary *mutViews = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableDictionary *mutMetrics = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableString *mutHFormat = [NSMutableString stringWithCapacity:100];
        
        [mutViews setObject:_textView forKey:@"_textView"];
        [mutMetrics setObject:@5.0 forKey:@"tagSpacing"];
        
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
            
            [mutHFormat appendString:@"H:|"];
            
            int idx = 0;
            for (TagData *tag in _dailyDo.tags) {
                TagTokenView *tagToken = [[TagTokenView alloc] initWithTag:NSLocalizedString(tag.name, nil)];
                tagToken.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:tagToken];
                [_tagTokens addObject:tagToken];
                
                [mutViews setObject:tagToken forKey:[NSString stringWithFormat:@"tagToken_%d", idx]];
                
                NSString *vFormat = [NSString stringWithFormat:@"V:[tagToken_%d(%f)]-%f-|", idx, tagToken.frame.size.height, (TagBlockHeight - tagToken.frame.size.height)/2];
                [tConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vFormat
                                                                                          options:NSLayoutFormatAlignAllBottom
                                                                                          metrics:[mutMetrics copy]
                                                                                            views:[mutViews copy]]];
                
                [mutHFormat appendFormat:@"[tagToken_%d(%f)]", idx, tagToken.frame.size.width];
                if (idx < [_dailyDo.tags count] - 1) {
                    [mutHFormat appendString:@"-tagSpacing-"];
                }
                
                idx ++;
            }
        }
        
        [tConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[mutHFormat copy]
                                                                                  options:0
                                                                                  metrics:[mutMetrics copy]
                                                                                    views:[mutViews copy]]];
        
    }
    
    [self addConstraints:[tConstraints copy]];
}

#pragma mark - Actions

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    if (_dailyDo) {
        _textView.text = [_dailyDo presentedText];
        _textView.font = [UIFont systemFontOfSize:TextViewTextFontSize];
    }
}

@end
