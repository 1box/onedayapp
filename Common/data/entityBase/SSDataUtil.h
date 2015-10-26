//
//  SSDataUtil.h
//  Gallery
//
//  Created by Dianwei Hu on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSEntityBase.h"

@interface SSDataUtil : NSObject

+ (NSString*)compareKeyForEntity:(SSEntityBase*)entity;
+ (NSString*)compareKeyForData:(NSDictionary*)data primaryKeys:(NSArray*)pks;
@end
