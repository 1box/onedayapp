//
//  MainCartoonManager.m
//  OneDay
//
//  Created by Yu Tianhang on 13-2-26.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "CartoonManager.h"
#import "AddonManager.h"

@interface CartoonManager() {
    int _cartoonIndex;
}

@property (nonatomic) NSTimer *changeTimer;
@end

@implementation CartoonManager

static CartoonManager *_sharedManager;
+ (CartoonManager *)sharedManager
{
    @synchronized(self) {
        if(!_sharedManager) {
            _sharedManager = [[CartoonManager alloc] init]; 
        }
    }
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

- (void)startChangeCartoonTimer
{
    if (randomCartoonSwitch()) {
        if(_changeTimer) {
            [_changeTimer invalidate];
        }
        
        [self performSelector:@selector(handleChangeCartoonTimer) withObject:nil afterDelay:0.1f];
        self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(handleChangeCartoonTimer) userInfo:nil repeats:YES];
    }
    else {
        [self performBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ODCartoonManagerRunAllCartoonsNotification
                                                                object:self];
        } afterDelay:0.1];
    }
}

- (void)stopChangeCartoonTimer
{
    if (randomCartoonSwitch()) {
        [_changeTimer invalidate];
        self.changeTimer = nil;
    }
}

#pragma mark - private

- (void)handleChangeCartoonTimer
{
    NSInteger addonsCount = [[AddonManager sharedManager] addonsCount];
    
    if(addonsCount != 0) {
        int randomIndex = arc4random()%addonsCount;
        if (randomIndex == _cartoonIndex) {
            randomIndex = (randomIndex + 1)%addonsCount;
        }
        
        _cartoonIndex = randomIndex;
        [[NSNotificationCenter defaultCenter] postNotificationName:ODCurrentCartoonIndexChangedNotification
                                                            object:self
                                                          userInfo:@{kODCurrentCartoonIndexChangedNotificationIndexKey : [NSNumber numberWithInt:_cartoonIndex]}];
    }
}
@end
