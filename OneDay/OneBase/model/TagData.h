//
//  TagData.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "SSEntityBase.h"

@class DailyDoBase;

@interface TagData : SSEntityBase

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *superTag;
@property (nonatomic, strong) NSNumber *createTime;

@property (nonatomic, strong) NSSet *dailyDos;
@end

@interface TagData (CoreDataGeneratedAccessors)

- (void)addDailyDosObject:(DailyDoBase *)value;
- (void)removeDailyDosObject:(DailyDoBase *)value;
- (void)addDailyDos:(NSSet *)values;
- (void)removeDailyDos:(NSSet *)values;
@end
