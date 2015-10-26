//
//  AlarmRepeatTypeCellView.m
//  OneDay
//
//  Created by Kimimaro on 13-5-17.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmRepeatTypeCellView.h"

@implementation AlarmRepeatTypeCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setChecked:(BOOL)checked
{
    [super setChecked:checked];
    if (self.isChecked) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
