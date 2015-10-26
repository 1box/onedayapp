//
//  DailyDoActionHelper.h
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DailyDoActionType) {
    DailyDoActionTypeNone = 0,
    DailyDoActionTypeMoveToTomorrow = 1UL,              // 1
    DailyDoActionTypeQuickAdd = (1UL << 1),             // 2
    DailyDoActionTypeShowAllUndos = (1UL << 2),         // 4
    DailyDoActionTypeCashMonthSummary = (1UL << 3),     // 8
    DailyDoActionTypeCashYearSummary = (1UL << 4),      // 16
    DailyDoActionTypeAlarmNotification = (1UL << 5),    // 32
    DailyDoActionTypeClearAllBlank = (1UL << 6)         // 64
};


@class DailyDoBase;
@class AddonData;
@class DailyDoActionHelper;


@protocol DailyDoActionHelperDelegate <NSObject>
@optional
- (void)dailyDoActionHelper:(DailyDoActionHelper *)helper doActionForType:(DailyDoActionType)actionType;
@end


@interface DailyDoActionHelper : NSObject

@property (nonatomic, weak) id<DailyDoActionHelperDelegate> delegate;

+ (DailyDoActionHelper *)sharedHelper;

- (NSDictionary *)indexHashForActionType:(DailyDoActionType)actionType;

- (void)move:(DailyDoBase *)todayDo toTomorrow:(DailyDoBase *)tomorrowDo;
- (void)quickAddTodo:(DailyDoBase *)dailyDo;
- (void)showAllUndos:(AddonData *)addon;
- (void)showCashMonthSummary;
- (void)showCashYearSummary;
- (void)showWorkoutAlarms;
- (void)clearAllBlank:(AddonData *)addon;

@end
