//
//  SMConstants.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-16.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SMLineNumberRegEx @"^\\d+. "
#define SMSeparator @"\n"
#define SMChineseAuxWord @"了"
#define SMEnglishPluralSuffix @"s"
#define SMCommonPrefix @" "


typedef NS_ENUM(NSInteger, SmarkDetectType) {
    SmarkDetectTypeDate = 1UL,         // 时间 1
    SmarkDetectTypeDuration = (1UL << 1),     // 时长 2
    
    SmarkDetectTypeMoney = (1UL << 2),    // 货币单位 4
    SmarkDetectTypeCaloric = (1UL << 3),  // 热量单位 8
    SmarkDetectTypeDistance = (1UL << 4), // 距离单位 16
    SmarkDetectTypeFrequency = (1UL << 5),    // 次数 32
    SmarkDetectTypeQuantity = (1UL << 6)      // 个数 64
};

static inline NSArray* numberSmark() {
    return @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"."];
}

/*
 * 2) duration
 * must order by '小时', '时'
 * must order by 'hours', 'hour', 'h'
 * [(（](\d+(\.\d{1,2})?(hours|hour|h|小时|时))?(\d+(\.\d{1,2})?(minutes|minute|m|分钟|分))?[)）]
 */
#define SMDurationRegEx @"[(（](\\d+(\\.\\d{1,2})?(hours|hour|h|小时|时))?(\\d+(\\.\\d{1,2})?(minutes|minute|m|分钟|分))?[)）]"   // will match '()'
static inline NSArray* durationFaultSmark() {
    return @[@"（）", @"（)", @"(）", @"()"];
}

static inline NSArray* durationBeginSmark() {
    return @[@"(", @"（"];
}

static inline NSArray* durationEndSmark() {
    return @[@")", @"）"];
}

static inline NSArray* durationHourUnit() {
    return @[@"hours", @"hour", @"h", @"小时", @"时"];
}

static inline NSArray* durationMinuteUnit() {
    return @[@"minutes", @"minute", @"m", @"分钟", @"分"];
}

/*
 * 3) money unit
 * only support yuan and Dollar
 * case insensitive
 * ^$ match at the line breaks
 * (\+|-| |收入|赚|中|花|丢|消费|支出|^)(了)?\d+(\.\d{1,2})?(\$|dollars|dollar|d|yuan|RMB|元|块)
 * 1人民币元=0.1608美元   // 2013.1.15
 * 1美元=6.2192人民币元
 */
#define SMMoneyRegEx @"(\\+|-| |spend|spentgain|cost|make|earn|pay|lose|lost|收入|赚|中|花|丢|消费|支出|^)(了)?\\d+(\\.\\d{1,2})?(\\$|dollars|dollar|d|yuan|RMB|元|块)"
#define RMBToDollarRate 0.1608
#define DollarToRMBRate 6.2192

static inline NSArray* moneyUnitBeginSmark() {
    return @[@"+", @"-", @" ", @"spend", @"spent" @"gain", @"cost", @"make", @"earn", @"pay", @"lose", @"lost", @"收入", @"赚", @"中", @"花", @"丢", @"消费", @"支出"];
}

static inline NSArray* positiveMoneyUnitBeginSmark() {
    return @[@"+", @"gain", @"make", @"earn", @"收入", @"赚", @"中", @""];
}

static inline NSArray* negativeMoneyUnitBeginSmark() {
    return @[@"-", @" ", @"spend", @"spent", @"cost", @"pay", @"lose", @"lost", @"花", @"丢", @"消费", @"支出"];
}

static inline NSArray* moneyUnits() {
    return @[@"$", @"dollars", @"dollar", @"d", @"yuan", @"RMB", @"元", @"块"];
}

static inline NSArray* RMBUnits() {
    return @[@"yuan", @"RMB", @"元", @"块"];
}

static inline NSArray* dollarUnits() {
    return @[@"$", @"dollars", @"dollar", @"d",];
}

/*
 * 4) caloric unit
 * auto add 's' for plural form
 * only support single unit
 * (\+|-|减少|减|消耗|摄取|摄入|增加|胖|吃|长| |^)(了)?(\+|-)?\d+(\.\d+)?(kilojoule|joule|KJ|J|kilocalorie|calorie|cal|卡路里|大卡|卡|焦耳|千焦|焦)
 * case insensitive
 * ^$ match at the line breaks
 * 1千卡=1大卡=1000卡=1000卡路里 =4186焦耳=4.186千焦
 */
#define SMCaloricRegEx @"(\\+|-|lose|lost|gain|fat|have|eat|absorb|减少|减|消耗|摄取|摄入|增加|胖|吃|长| |^)(了)?(\\+|-)?\\d+(\\.\\d+)?(kilojoule|joule|KJ|J|kilocalorie|calorie|cal|卡路里|大卡|卡|焦耳|千焦|焦)"
#define CalToJouleRate 4.186
static inline NSArray* caloricUnitBeginSmark() {
    return @[@"+", @"-", @"lose", @"lost", @"gain", @"fat", @"have", @"eat", @"absorb", @"减少", @"减", @"消耗", @"摄取", @"摄入", @"增加", @"胖", @"吃", @"长", @" "];
}

static inline NSArray* positiveCaloricUnitBeginSmark() {
    return @[@"+", @"gain", @"fat", @"have", @"eat", @"absorb", @"摄取", @"摄入", @"增加", @"胖", @"吃", @"长", @" ", @""];
}

static inline NSArray* negativeCaloricUnitBeginSmark() {
    return @[@"-", @"lose", @"lost", @"减少", @"减", @"消耗"];
}

static inline NSArray* caloricUnits() {
    return @[@"kilocalorie", @"calorie", @"cal", @"KJ", @"J", @"kilojoule", @"joule", @"大卡", @"千卡", @"卡路里", @"卡", @"焦耳", @"千焦", @"焦"];
}

static inline NSArray* signleCalorieUnits() {
    return @[@"calorie", @"cal", @"卡路里", @"卡"];
}

static inline NSArray* jouleUnits() {
    return @[@"joule", @"J", @"焦耳", @"焦"];
}

static inline NSArray* kiloCalUnits() {
    return @[@"kilocalorie", @"大卡", @"千卡"];
}

static inline NSArray* kiloJouleUnits() {
    return @[@"KJ", @"kilojoule", @"千焦"];
}

/*
 * 5) distance unit
 * only support km, m
 * ignore 's' for plural form
 * case insensitive
 * ^$ match at the line breaks
 * (走|跑步|跑|运动| |^)(了)?\d+(\.\d{1,2})?(((kilometer|kilometre|meter|metre|m|km)s?)|公里|千米|米)
 */
#define SMDistanceRegEx @"(run|walk|do|走|跑步|跑|运动| |^)(了)?\\d+(\\.\\d{1,2})?(((kilometer|kilometre|meter|metre|m|km)s?)|公里|千米|米)"
static inline NSArray* distanceUnitBeginSmark() {
    return @[@"run", @"walk", @"do", @"跑", @"走", @"跑步", @"运动", @" "];
}

static inline NSArray* distanceUnits() {
    return @[@"kilometer", @"kilometre", @"meter", @"metre", @"km", @"m", @"千米", @"米", @"公里"];
}

/*
 * 6) frequency
 * case insensitive
 * ^$ match at the line breaks
 * ( |做|^)\d+(\.\d{1,2})?(times|time|次数|次|回)
 */
#define SMFrequencyRegEx @"( |do|做|^)\\d+(\\.\\d{1,2})?(times|time|次数|次|回)"
static inline NSArray* frequencyUnitBeginSmark() {
    return @[@" ", @"do", @"做"];
}

static inline NSArray* frequencyUnits() {
    return @[@"times", @"time", @"次数", @"次", @"回"];
}

/*
 * 7) quantity
 * case insensitive
 * ^$ match at the line breaks
 * ( |^)\d+(\.\d{1,2})?(个)
 */
#define SMQuantityRegEx @"( |^)\\d+(\\.\\d{1,2})?(个)"
static inline NSArray* quantityUnitBeginSmark() {
    return @[@" "];
}

static inline NSArray* quantityUnits() {
    return @[@"个"];
}

@interface SMConstants : NSObject
@end
