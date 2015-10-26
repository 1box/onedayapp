//
//  FeedbackViewController.h
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewControllerBase.h"
#import "UMFeedback.h"

@interface FeedbackViewController : KMViewControllerBase <UMFeedbackDataDelegate> {
    
    UMFeedback *feedbackClient;
}

@property (nonatomic) IBOutlet UITextField *mTextField;
@property (nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic) IBOutlet UIToolbar   *mToolBar;

@property (nonatomic)  NSArray *mFeedbackDatas;

- (IBAction)sendFeedback:(id)sender;

@end
