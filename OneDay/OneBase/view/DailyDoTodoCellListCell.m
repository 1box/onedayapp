//
//  TodoPropertyListCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoTodoCellListCell.h"
#import "TodoData.h"
#import "DailyDoBase.h"

#define LeftPadding 5.f
#define SelfWidth 255.f
#define ContentLabelWidth 195.f

@implementation DailyDoTodoCellListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CGFloat)heightOfCellForToDo:(TodoData *)todo
{
    CGFloat ret = heightOfContent(todo.content, ContentLabelWidth, 14.f);
    ret = MAX(ret, 22.f);
    return ret;
}

- (void)setTodo:(TodoData *)todo
{
    _todo = todo;
    
    if (_todo) {
        _checkbox.selected = [_todo.check boolValue];
        _enumLabel.text = [NSString stringWithFormat:@"%d. ", [_todo.index intValue] + 1];
        _contentLabel.text = _todo.content;
    }
}

@end
