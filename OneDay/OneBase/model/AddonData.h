//
//  AddonData.h
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSEntityBase.h"

@interface AddonData : SSEntityBase

@property (nonatomic, strong) NSString *dailyDoName;
@property (nonatomic, strong) NSNumber *orderIndex;
@property (nonatomic, strong) NSNumber *display;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *cartoon;
@property (nonatomic, strong) NSNumber *numberOfCartoons;
@property (nonatomic, strong) NSNumber *detectType;
@property (nonatomic, strong) NSNumber *showChecked;
@property (nonatomic, strong) NSString *tipImage;
@property (nonatomic, strong) NSNumber *passwordOn;

@property (nonatomic, strong) NSSet *dailyDos;
@property (nonatomic, strong) NSSet *alarms;

+ (void)loadDefaultDataFromDefaultPlist;
- (BOOL)removeBlankDailyDos;    // return YES for success

@end
