//
//  NSObject+NSObjectAdditions.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-2.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObjectAdditions)

// quick way to delay perform
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

// return a dictionary properties' names & values
- (NSDictionary *)properties_apsWithStopSuper:(id)stopSuper;
- (NSDictionary *)properties_aps;

@end
