//
//  SaveTagsManager.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-2.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagManager : NSObject

+ (TagManager *)sharedManager;

- (void)loadDefaultTagsFromPlist;
- (NSArray *)tags;
@end
