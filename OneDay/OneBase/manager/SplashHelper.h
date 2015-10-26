//
//  SplashHelper.h
//  OneDay
//
//  Created by Kimimaro on 13-5-10.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SplashHelper;

typedef void (^LoadFlipSplashFinishedBlock)(SplashHelper *helper);


@interface SplashHelper : NSObject

@property (nonatomic, readonly) BOOL splashFliped;
@property (nonatomic, readonly) BOOL splashFinished;

+ (SplashHelper *)sharedHelper;

- (void)addFlipedBlock:(LoadFlipSplashFinishedBlock)flipedBlock;
- (void)addFinishedBlock:(LoadFlipSplashFinishedBlock)finishedBlock;
- (void)prepareSplashAnimationView;
- (void)splashFlipAnimation;

@end
