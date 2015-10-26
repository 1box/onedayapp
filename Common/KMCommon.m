//
//  KMCommon.m
//  OneDay
//
//  Created by Kimi Yu on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "KMCommon.h"
#import "UIDevice-Hardware.h"


@implementation KMCommon

+ (BOOL)isPadDevice
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)is568Screen
{
    return (fabs((double)[[UIScreen mainScreen] bounds].size.height-(double)568) < DBL_EPSILON);
}

+ (BOOL)isJailBroken 
{
	NSString *filePath = @"/Applications/Cydia.app";
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return YES;
	}
	
	filePath = @"/private/var/lib/apt";
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return YES;
	}
	
	return NO;
}

#pragma mark - app parameters

+ (NSString *)appName
{
    static NSString *__appName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__appName) {
            __appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"];
        }
    });
    return __appName;
}

+ (NSString *)versionName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)OSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)appDisplayName
{
    static NSString *__appDisplayName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__appDisplayName) {
            __appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            if (!__appDisplayName) {
                __appDisplayName = [KMCommon appName];
            }
        }
    });
    return __appDisplayName;
}

+ (NSString *)platformName
{
    NSString *result = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";
    return result;
}

+ (NSString *)channelName
{
    static NSString *__channelName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __channelName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ChannelName"];
    });
    
    return __channelName;
}

+ (NSString *)deviceType
{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)bundleIdentifier
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)currentLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)carrierName
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return [carrier carrierName];
}

+ (NSString *)carrierMCC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [carrier mobileCountryCode];
}

+ (NSString *)carrierMNC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [carrier mobileNetworkCode];
}

+ (CGSize)resolution
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    CGSize resolution = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
    return resolution;
}

#pragma mark - tool

+ (UIViewController *)topMostViewControllerFor:(UIResponder *)responder
{
	UIResponder *topResponder = responder;
    if(!topResponder) {
        topResponder = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
    }
    
	while(topResponder && ![topResponder isKindOfClass:[UIViewController class]]) {
		topResponder = [topResponder nextResponder];
	}
    
    if ([topResponder isKindOfClass:[UIViewController class]]) {
        UIViewController *tController = (UIViewController *)topResponder;
        while (tController.presentedViewController) {
            tController = tController.presentedViewController;
        }
        topResponder = tController;
    }
	
	return (UIViewController *)topResponder;
}

+ (UINavigationController *)topMostNavigationControllerFor:(UIResponder*)responder
{
    UIViewController *top = [KMCommon topMostViewControllerFor:responder];
    if ([top isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)top;
    }
    else if (top.navigationController) {
        return top.navigationController;
    }
    else {
        return nil;
    }
}

+ (UINavigationController *)rootNavigationController
{
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *ret = nil;
    if ([appDelegate respondsToSelector:@selector(nav)]) {
        ret = [appDelegate performSelector:@selector(nav)];
    }
    return ret;
}

static AVAudioPlayer *_player = nil;
+ (void)playSound:(NSString *)fileName
{
    [_player stop];
	NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    
    //Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    NSError *error = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
    
    if (!error) {
        [_player play];
    }
    else {
        SSLog(@"SSCommon play sound error:%@", error);
    }
}

#pragma mark - url utils

+ (NSDictionary *)parametersOfURLString:(NSString *)urlString
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSArray *patterns = [urlString componentsSeparatedByString:@"&"];
    for(NSString *pattern in patterns)
    {
        NSArray *part = [pattern componentsSeparatedByString:@"="];
        if([part count] == 2)
        {
            [result setObject:[part objectAtIndex:1] forKey:[part objectAtIndex:0]];
        }
    }
    
    return result;
}

+ (NSString *)URLStringByAddingParamsForURLString:(NSString *)strURL params:(NSString *)params 
{
	NSString *sep = @"&";
	NSRange range = [strURL rangeOfString:@"?"];
	if (range.location==NSNotFound) {
		sep = @"?";
	}
	NSString *newURL = [NSString stringWithFormat:@"%@%@%@", strURL, sep, params];
	return newURL;
}

+ (NSString *)customURLStringFromString:(NSString *)urlStr
{
    NSRange range = [urlStr rangeOfString:@"?"];
    NSString *sep = (range.location == NSNotFound) ? @"?" : @"&";
    NSMutableString *string = [NSMutableString stringWithString:urlStr];
    
    if([string rangeOfString:@"device_platform"].location == NSNotFound) {
        [string appendFormat:@"%@device_platform=%@", sep, [KMCommon platformName]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"channel"].location == NSNotFound) {
        [string appendFormat:@"%@channel=%@", sep, [KMCommon channelName]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"app_name"].location == NSNotFound) {
        [string appendFormat:@"%@app_name=%@", sep, [KMCommon appName]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"device_type"].location == NSNotFound) {
        [string appendFormat:@"%@device_type=%@", sep, [[UIDevice currentDevice] platformString]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"os_version"].location == NSNotFound) {
        [string appendFormat:@"%@os_version=%@", sep, [KMCommon OSVersion]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"version_code"].location == NSNotFound) {
        [string appendFormat:@"%@version_code=%@", sep, [KMCommon versionName]];
    }

    return string;
}

@end
