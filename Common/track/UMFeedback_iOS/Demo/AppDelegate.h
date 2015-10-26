//
//  AppDelegate.h
//  Demo
//
//  Created by iOS@Umeng on 9/27/12.
//  Copyright (c) 2012 iOS@Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@end
