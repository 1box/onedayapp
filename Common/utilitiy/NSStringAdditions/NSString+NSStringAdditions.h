//
//  NSString+NSStringAdditions.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-12.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KMEmptyString(x) (![x isKindOfClass:[NSString class]] || x.length == 0)

@interface NSString (NSStringAdditions)

- (BOOL)isInputComponent;
- (NSString *)stringByTrimmingStrings:(NSArray *)strings;

// SBC&DBC case string convert, only support ":" now
- (NSString *)SBCString;
- (NSString *)DBCString;

@end
