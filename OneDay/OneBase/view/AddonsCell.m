//
//  AddonsCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AddonsCell.h"
#import "AddonData.h"
#import "DailyDoManager.h"

#define VerticalPadding 5.f

@implementation AddonsCell

- (void)setAddon:(AddonData *)addon
{
    _addon = addon;
    if (_addon) {
        _addonIconView.image = [UIImage imageNamed:_addon.icon];
        _addonNameLabel.text = [[DailyDoManager sharedManager] sloganForDoName:_addon.dailyDoName];
    }
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
