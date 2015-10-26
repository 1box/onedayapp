//
//  NSObject+NSObjectAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-2.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSObject+NSObjectAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (NSObjectAdditions)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block
{
    block();
}

- (NSDictionary *)properties_apsWithStopSuper:(Class)stopSuper
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    Class currentSuper = [self class];
    do {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentSuper, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            //        NSString *propertyName = [[[NSString alloc] initWithCString:property_getName(property)] autorelease];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            id propertyValue = [self valueForKey:(NSString *)propertyName];
            if (propertyValue != nil) {
                [props setObject:propertyValue forKey:propertyName];
            }
        }
        free(properties);
        
        currentSuper = [currentSuper superclass];
        
    } while (currentSuper != [stopSuper superclass] && currentSuper != [NSObject class]);
    
    return props;
}

- (NSDictionary *)properties_aps
{
    return [self properties_apsWithStopSuper:[NSObject class]];
}

//- (NSDictionary *)properties_aps
//{
//    NSMutableDictionary *props = [NSMutableDictionary dictionary];
//    unsigned int outCount, i;    
//    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
//    
//    for (i = 0; i < outCount; i++) {
//        objc_property_t property = properties[i];
////        NSString *propertyName = [[[NSString alloc] initWithCString:property_getName(property)] autorelease];
//        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
//        id propertyValue = [self valueForKey:(NSString *)propertyName];
//        if (propertyValue != nil) {
//            [props setObject:propertyValue forKey:propertyName];   
//        }
//    }
//    free(properties);
//    
//    return props;
//}

@end
