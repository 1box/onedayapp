//
//  LoggedDoListCell.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMUnfoldTableCell.h"

@class DailyDoBase;
@class DailyDoPresentView;

@interface DailyDoLoggedCell : KMUnfoldTableCell

@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *completeLabel;
@property (nonatomic) IBOutlet DailyDoPresentView *presentView;

@property (nonatomic) DailyDoBase *loggedDo;

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfolded:(BOOL)unfolded;
@end
