//
//  TodoPropertyListCell.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMTableViewCell.h"

@class TodoData;

@interface DailyDoTodoCellListCell : KMTableViewCell
@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet UILabel *enumLabel;
@property (nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic) TodoData *todo;

+ (CGFloat)heightOfCellForToDo:(TodoData *)todo;
@end
