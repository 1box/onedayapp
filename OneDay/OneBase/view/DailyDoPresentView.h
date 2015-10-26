//
//  DailyDoPresentView.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMViewBase.h"

@class DailyDoBase;

@interface DailyDoPresentView : KMViewBase

@property (nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) DailyDoBase *dailyDo;

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo;
- (void)refreshUI;

@end

