//
//  AppDelegate.h
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegateBase : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (nonatomic) UINavigationController *nav;

// extended
+ (NSString *)bundleIDForRate;
@end
