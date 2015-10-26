//
//  DailyDoViewHelper.h
//  OneDay
//
//  Created by Kimimaro on 13-6-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LoggedDoUnfoldDefaultIndex -1

@class AddonData;


@interface DailyDoViewHelper : NSObject

@property (nonatomic, readonly) BOOL todayDoUnfold;
@property (nonatomic, readonly) BOOL tomorrowDoUnfold;
@property (nonatomic, readonly) int loggedDoUnfoldIndex;

@property (nonatomic) BOOL allUnfold;
@property (nonatomic) AddonData *addon;

- (BOOL)loggedUnfoldForIndex:(NSInteger)index;

- (void)updateTodayDoUnfold;
- (void)updateTomorrowDoUnfold;
- (void)updateLoggedUnfoldForIndex:(NSInteger)index;

@end
