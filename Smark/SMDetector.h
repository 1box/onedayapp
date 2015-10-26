//
//  SMDetector.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-16.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMConstants.h"

@interface SMDetector : NSObject

+ (SMDetector*)defaultDetector;

- (NSUInteger)lineNumberForString:(NSString *)aString;
- (NSArray *)itemInString:(NSString *)aString byType:(SmarkDetectType)type;

/*
 * return RMB rate for smark money
 * return kilocalorie rate for smark caloric
 */
- (id)valueInString:(NSString *)aString byType:(SmarkDetectType)type;
@end
