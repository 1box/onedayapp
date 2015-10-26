//
//  DailyDoDateView.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-16.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoDateView.h"
#import "DailyDoBase.h"
#import "UILabel+UILabelAdditions.h"
#import "KMDateUtils.h"

#define DayLabelFontSize 18.f
#define TitleLabelFontSize 12.f
#define MonthAndYearLabelFontSize 10.f

#define HorizontalPadding 5.f
#define VerticalPadding 8.f
#define BubbleOriginX 60.f

#define TitleLeftMargin 15.f
#define TitleRightMargin 5.f
#define TitleVerticalMargin 5.f
#define DayLabelBottomMargin 6.f

@implementation DailyDoDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

+ (CGFloat)heightForDailyDo:(DailyDoBase *)dailyDo fixWidth:(CGFloat)width
{
    CGFloat contentHeight = 2*VerticalPadding;
    
    CGFloat titleFixWidth = width - BubbleOriginX - HorizontalPadding - TitleLeftMargin - TitleRightMargin;
    CGFloat titleHeight = heightOfContent([dailyDo todayText], titleFixWidth, TitleLabelFontSize) + 2*TitleVerticalMargin;
    CGFloat dateHeight = DayLabelFontSize + DayLabelBottomMargin + MonthAndYearLabelFontSize;
    
    contentHeight += MAX(titleHeight, dateHeight);
    
    return contentHeight;
}

#pragma mark - public

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    if (_dailyDo) {
        NSDate *tDate = [NSDate dateWithTimeIntervalSince1970:[_dailyDo.createTime doubleValue]];
        NSDateComponents *tComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tDate];
        
        _dayLabel.text = [NSString stringWithFormat:@"%d", tComponents.day];
        
        NSString *monthString = [[YearToDayFormatter() shortMonthSymbols] objectAtIndex:tComponents.month - 1];
        _monthAndYearLabel.text = [NSString stringWithFormat:@"%@, %@", monthString, [NSString stringWithFormat:@"%d", tComponents.year]];
        
        _titleLabel.text = [_dailyDo todayText];
        
        UIImage *bubble = [UIImage imageNamed:@"today_bubble.png"];
        bubble = [bubble stretchableImageWithLeftCapWidth:bubble.size.width/2 topCapHeight:bubble.size.height - 10.f];
        _bubbleImage.image = bubble;
    }
}
@end
