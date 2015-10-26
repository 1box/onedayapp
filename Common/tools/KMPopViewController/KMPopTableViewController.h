//
//  KMPopTableViewController.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-4.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMPopViewController.h"

@interface KMPopTableViewController : KMPopViewController

- (NSInteger)cellCount;
- (CGFloat)cellHeight;
- (NSString *)tableViewTitle;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
