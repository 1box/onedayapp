//
//  KMCommon.h
//  OneDay
//
//  Created by Kimi Yu on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface KMCommon : NSObject

+ (BOOL)isPadDevice;
+ (BOOL)is568Screen;
+ (BOOL)isJailBroken;

// app parameters
+ (NSString *)appName;
+ (NSString *)versionName;
+ (NSString *)OSVersion;
+ (NSString *)appDisplayName;
+ (NSString *)platformName;
+ (NSString *)channelName;
+ (NSString *)deviceType;
+ (NSString *)bundleIdentifier;
+ (NSString *)currentLanguage;
+ (NSString *)carrierName;
+ (NSString *)carrierMCC;
+ (NSString *)carrierMNC;
+ (CGSize)resolution;

// tool
+ (UIViewController *)topMostViewControllerFor:(UIResponder *)responder;
+ (UINavigationController *)topMostNavigationControllerFor:(UIResponder*)responder;
+ (UINavigationController *)rootNavigationController;
+ (void)playSound:(NSString *)fileName;

// url utils
+ (NSDictionary *)parametersOfURLString:(NSString *)urlString;
+ (NSString *)URLStringByAddingParamsForURLString:(NSString *)strURL params:(NSString *)params;
+ (NSString *)customURLStringFromString:(NSString *)urlStr;

@end
