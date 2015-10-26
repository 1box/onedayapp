//
//  UndoCellView.m
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "UndoCellView.h"
#import "TodoData.h"
#import "KMModelManager.h"
#import "UILabel+UILabelAdditions.h"

#define TextWidth 245

@implementation UndoCellView

+ (CGFloat)heightForTodoData:(TodoData *)todo
{
    CGFloat ret = heightOfContent([todo pureContent], TextWidth, 13.f) + 20.f;
    ret = MAX(ret, 44.f);
    return ret;
}

- (void)setTodo:(TodoData *)todo
{
    _todo = todo;
    if (_todo) {
        _checkbox.enabled = ![todo.check boolValue];
        _contentLabel.text = [todo pureContent];
    }
}

- (IBAction)checkbox:(id)sender
{
    UIButton *checkBox = sender;
    checkBox.enabled = NO;
    
    _todo.check = @YES;
    [[KMModelManager sharedManager] saveContext:nil];
}

@end
