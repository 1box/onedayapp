//
//  RootVerticalToolbar.h
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootVerticalToolbar : UIView
@property (nonatomic) IBOutlet UIView *pageView;
@property (nonatomic) IBOutlet UILabel *pageLabel;

- (void)spinPageViewWithNumber:(int)number;
@end
