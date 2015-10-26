//
//  DailyDoDateView.h
//  OneDay
//
//  Created by Yu Tianhang on 12-12-16.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMViewBase.h"

@class DailyDoBase;

@interface DailyDoDateView : KMViewBase

@property (nonatomic) DailyDoBase *dailyDo;

@property (nonatomic) IBOutlet UILabel *dayLabel;
@property (nonatomic) IBOutlet UILabel *monthAndYearLabel;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UIImageView *bubbleImage;

+ (CGFloat)heightForDailyDo:(DailyDoBase *)dailyDo fixWidth:(CGFloat)width;
@end
