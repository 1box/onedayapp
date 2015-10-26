//
//  main.m
//  OwnDay
//
//  Created by Yu Tianhang on 13-2-20.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            SSLog(@"ex:%@, stack:%@", exception, [exception callStackSymbols]);
        }
        @finally {
            
        }
    }
}
