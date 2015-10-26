//
//  DailyDotomorrowCell.h
//  OneDay
//
//  Created by Yu Tianhang on 13-2-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMUnfoldTableCell.h"

@class DailyDoBase;
@class DailyDoPresentView;

@interface DailyDoTomorrowCell : KMUnfoldTableCell

@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *tomorrowDoLabel;
@property (nonatomic) IBOutlet DailyDoPresentView *presentView;

@property (nonatomic) DailyDoBase *tomorrowDo;

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfolded:(BOOL)unfolded;
@end
