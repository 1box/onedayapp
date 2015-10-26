//
//  SummaryCellView.h
//  OneDay
//
//  Created by Kimimaro on 13-5-13.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMCheckboxTableCell.h"

@interface SummaryCellView : KMCheckboxTableCell
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *summaryLabel;
@end
