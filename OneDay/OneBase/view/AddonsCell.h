//
//  AddonsCell.h
//  OneDay
//
//  Created by Yu Tianhang on 12-12-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMCheckboxTableCell.h"

@class AddonData;

@interface AddonsCell : KMCheckboxTableCell
@property (nonatomic) AddonData *addon;

@property (nonatomic) IBOutlet UIImageView *addonIconView;
@property (nonatomic) IBOutlet UILabel *addonNameLabel;
@end
