//
//  PasswordAddonCell.h
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMTableViewCell.h"

@interface PasswordAddonCell : KMTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *addonLabel;
@property (nonatomic, strong) IBOutlet UISwitch *passwordSwitch;

@end
