//
//  UMTableViewDemo.h
//  UMAppNetwork
//
//  Created by liu yu on 12/17/11.
//  Copyright (c) 2011 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPTableView.h"

@interface UMTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UMUFPTableViewDataLoadDelegate> {
    
    UMUFPTableView *_mTableView;
    
    UIView *_mLoadingWaitView;
    UILabel *_mLoadingStatusLabel;
    UIImageView *_mNoNetworkImageView;
    UIActivityIndicatorView *_mLoadingActivityIndicator;  
}

@end