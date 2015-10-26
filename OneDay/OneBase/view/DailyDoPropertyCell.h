//
//  DailyDoPropertyCell.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-30.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "KMTableViewCell.h"

@interface DailyDoPropertyCell : KMTableViewCell

@property (nonatomic) IBOutlet UIImageView *iconImage;
@property (nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) NSString *propertyKey;
@end
