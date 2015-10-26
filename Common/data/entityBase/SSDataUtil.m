//
//  SSDataUtil.m
//  Gallery
//
//  Created by Dianwei Hu on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SSDataUtil.h"

@implementation SSDataUtil

+ (NSString*)compareKeyForEntity:(SSEntityBase*)entity
{
    NSArray *pks = [[entity class] primaryKeys];
    NSMutableString *result = [NSMutableString stringWithCapacity:20];
    [pks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result appendFormat:@" %@ %@", obj, [entity valueForKeyPath:obj]];
    }];
    
    return result;
}

+ (NSString*)compareKeyForData:(NSDictionary*)data primaryKeys:(NSArray*)pks
{
    NSMutableString *result = [NSMutableString stringWithCapacity:20];
    [pks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result appendFormat:@" %@ %@", obj, [data objectForKey:obj]];
    }];
    
    return result;
}

@end
