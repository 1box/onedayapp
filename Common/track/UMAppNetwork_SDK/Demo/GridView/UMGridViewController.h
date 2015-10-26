//
//  UMIconListViewController.h
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPGridView.h"

@interface UMGridViewController : UIViewController<GridViewDelegate,GridViewDataSource, UMUFPTableViewDataLoadDelegate>
{
    int count;
    UMUFPGridView *_mGridView;
}

@end