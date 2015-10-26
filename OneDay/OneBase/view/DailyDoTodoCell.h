//
//  TodoPropertyCell.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoPropertyCell.h"

@class KMTableView;
@class DailyDoBase;

@interface DailyDoTodoCell : DailyDoPropertyCell
@property (nonatomic) IBOutlet KMTableView *listView;
@property (nonatomic) DailyDoBase *dailyDo;
+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo;
@end
