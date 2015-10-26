//
//  EntityBase.h
//  CoreDataTest
//
//  Created by Dianwei Hu on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>




@interface SSEntityBase : NSManagedObject
+ (id)entityWithDictionary:(NSDictionary*)dataDict;
+ (NSArray*)entitiesWithDataArray:(NSArray*)dataArray;

+ (id)insertEntityWithDictionary:(NSDictionary*)dictionary;
+ (id)insertEntityWithDictionary:(NSDictionary*)dictionary syncrhonizeWithStore:(BOOL)synchronize;
+ (NSArray*)insertEntitiesWithDataArray:(NSArray*)dataArray;
+ (NSArray*)insertEntitiesWithDataArray:(NSArray*)dataArray syncrhonizeWithStore:(BOOL)synchronize;

#pragma mark - protected
+ (NSArray*)primaryKeys;
+ (NSString*)entityName;
// if the keys is updateIgnored and the original value is not null or specified value, it will not be updated
// e.g, @"behotTime" : @"0" means the behotTime != 0 should not be updated
+ (NSDictionary*)updateIgnoredKeys;
+ (NSDictionary*)keyMapping;
+ (id)dataEntityWithInsert:(BOOL)insert;
+ (NSString*)configuratonName;
+ (void)updateEntity:(SSEntityBase*)entity withData:(NSDictionary*)dataDict;
- (void)updateWithDictionary:(NSDictionary*)dataDict;
+ (NSEntityDescription*)entityDescription;


// Default implementation is to update each entity with each data
// If entity has relationship, sub class should overwrite this method to improve performance.
+ (void)updateEntities:(NSArray*)entities withDataArray:(NSArray*)dataArray;
@end
