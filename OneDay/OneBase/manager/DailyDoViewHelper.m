//
//  DailyDoViewHelper.m
//  OneDay
//
//  Created by Kimimaro on 13-6-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyDoViewHelper.h"
#import "AddonData.h"

#define kDailyDoViewAllUnfoldDictUserDefaultKey @"kDailyDoViewAllUnfoldDictUserDefaultKey"


@interface DailyDoViewHelper ()
@property (nonatomic, readwrite) BOOL todayDoUnfold;
@property (nonatomic, readwrite) BOOL tomorrowDoUnfold;
@property (nonatomic, readwrite) int loggedDoUnfoldIndex;
@end


@implementation DailyDoViewHelper

//static DailyDoViewHelper *_sharedHelper = nil;
//+ (DailyDoViewHelper *)sharedHelper
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _sharedHelper = [[DailyDoViewHelper alloc] init];
//    });
//    return _sharedHelper;
//}
//
//+ (id)alloc
//{
//    NSAssert(_sharedHelper == nil, @"Attempt alloc second instance for a singleton.");
//    return [super alloc];
//}

- (id)init
{
    self = [super init];
    if (self) {
        _todayDoUnfold = YES;
        _tomorrowDoUnfold = NO;
        _loggedDoUnfoldIndex = LoggedDoUnfoldDefaultIndex;
    }
    return self;
}

#pragma mark - setter&getter

- (BOOL)todayDoUnfold
{
    return _todayDoUnfold || self.allUnfold;
}

- (BOOL)tomorrowDoUnfold
{
    return _tomorrowDoUnfold || self.allUnfold;
}

- (BOOL)loggedUnfoldForIndex:(NSInteger)index
{
    BOOL ret = (_loggedDoUnfoldIndex == index) || self.allUnfold;
    return ret;
}

- (BOOL)allUnfold
{
    if (!_addon) {
        return NO;
    }
    
    if ([NSUserDefaults firstTimeUseKey:kDailyDoViewAllUnfoldDictUserDefaultKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionary] forKey:kDailyDoViewAllUnfoldDictUserDefaultKey];
    }
    
    NSDictionary *allUnfoldDict = [[NSUserDefaults standardUserDefaults] objectForKey:kDailyDoViewAllUnfoldDictUserDefaultKey];
    if (![allUnfoldDict.allKeys containsObject:_addon.dailyDoName]) {
        return NO;
    }
    
    return [[allUnfoldDict objectForKey:_addon.dailyDoName] boolValue];
}

- (void)setAllUnfold:(BOOL)allUnfold
{
    if (_addon) {
        NSMutableDictionary *mutAllUnfoldDict = [[[NSUserDefaults standardUserDefaults] objectForKey:kDailyDoViewAllUnfoldDictUserDefaultKey] mutableCopy];
        [mutAllUnfoldDict setObject:[NSNumber numberWithBool:allUnfold] forKey:_addon.dailyDoName];
        
        [[NSUserDefaults standardUserDefaults] setObject:[mutAllUnfoldDict copy] forKey:kDailyDoViewAllUnfoldDictUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)updateTodayDoUnfold
{
    _todayDoUnfold = !_todayDoUnfold;
}

- (void)updateTomorrowDoUnfold;
{
    _tomorrowDoUnfold = !_tomorrowDoUnfold;
}

- (void)updateLoggedUnfoldForIndex:(NSInteger)index;
{
    _loggedDoUnfoldIndex = (index == _loggedDoUnfoldIndex) ? LoggedDoUnfoldDefaultIndex : index;
}

@end
