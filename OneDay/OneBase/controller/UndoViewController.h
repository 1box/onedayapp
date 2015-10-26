//
//  UndosViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AddonData;

@interface UndoViewController : KMViewControllerBase

@property (nonatomic) AddonData *addon;

- (IBAction)moveAllToTomorrow:(id)sender;
- (IBAction)checkAll:(id)sender;

@end
