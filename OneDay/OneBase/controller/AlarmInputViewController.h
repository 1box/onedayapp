//
//  AlarmInputViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AlarmData;

@interface AlarmInputViewController : KMViewControllerBase
@property (nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) AlarmData *alarm;
@end
