//
//  UMTableViewController_N.h
//  UMUFPDemo
//
//  Created by liuyu on 12/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPTableView.h"

@interface UMTableViewController_N : UIViewController <UITableViewDelegate, UITableViewDataSource, UMUFPTableViewDataLoadDelegate>

@property (nonatomic, retain) UMUFPTableView *mTableView;

@end
