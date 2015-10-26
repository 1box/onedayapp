//
//  UndoCellView.h
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMTableViewCell.h"

@class TodoData;

@interface UndoCellView : KMTableViewCell

@property (nonatomic) TodoData *todo;
@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet UILabel *contentLabel;

+ (CGFloat)heightForTodoData:(TodoData *)todo;
- (IBAction)checkbox:(id)sender;

@end
