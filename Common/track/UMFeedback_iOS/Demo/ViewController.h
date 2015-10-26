//
//  ViewController.h
//  Demo
//
//  Created by iOS@Umeng on 9/27/12.
//  Copyright (c) 2012 iOS@Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"

@interface ViewController : UIViewController <UMFeedbackDataDelegate> {
    UMFeedback *_umFeedback;
    IBOutlet UITextField *_nameField;
    IBOutlet UITextField *_emailField;
    IBOutlet UITextField *_contentField;
}
@property(nonatomic, strong) UMFeedback *umFeedback;
@property(nonatomic, retain) UITextField *nameField;
@property(nonatomic, retain) UITextField *emailField;
@property(nonatomic, retain) UITextField *contentField;

- (IBAction)checkNewReplies:(id)sender;
- (IBAction)nativeFeedback:(id)sender;
- (IBAction)webFeedback:(id)sender;

- (IBAction)editingEnded:(id)sender;

@end
