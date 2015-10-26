//
//  AddonListCellBase.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMUnfoldTableCell.h"

@class DailyDoBase;
@class DailyDoDateView;
@class DailyDoPresentView;

@interface DailyDoTodayCell : KMUnfoldTableCell

@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet DailyDoDateView *dateView;
@property (nonatomic) IBOutlet DailyDoPresentView *presentView;

@property (nonatomic) DailyDoBase *dailyDo;

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfold:(BOOL)unfold;
@end
