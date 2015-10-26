//
//  KMModelManager.h
//  OneDay
//
//  Created by Yu Tianhang on 13-1-19.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSEntityBase.h"

#define KMModelManagerRefreshAllDatabaseDataNotification @"KMModelManagerRefreshAllDatabaseDataNotification"
#define KMModelManagerRefreshAllViewsNotification @"KMModelManagerRefreshAllViewsNotification"

@interface KMModelManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (KMModelManager *)sharedManager;

- (void)start;
- (BOOL)saveContext:(NSError**)error;

#pragma mark - insert & updates
// this method checks primary key but doesn't save by default.
- (BOOL)insertOrUpdateEntity:(SSEntityBase**)entity error:(NSError**)error;

// if check is NO, entity is always inserted into store
// if check and has duplicate, entity is updated with the one associated with the same primary keys from core data
- (BOOL)insertOrUpdateEntity:(SSEntityBase **)entity checkPrimaryKey:(BOOL)check save:(BOOL)save error:(NSError**)error;

// entities must has the same entityDescription
- (BOOL)insertOrUpdateEntities:(NSMutableArray*)entities error:(NSError**)error;
- (BOOL)insertOrUpdateEntities:(NSArray *)entities checkPrimaryKey:(BOOL)check save:(BOOL)save error:(NSError**)error;

#pragma mark - remove
- (BOOL)removeEntities:(NSArray*)entities
                  save:(BOOL)save 
                 error:(NSError**)error;
- (BOOL)removeEntitiesWithConditions:(NSArray*)condition
                   entityDescription:(NSEntityDescription*)entityDescription
                                save:(BOOL)save 
                               error:(NSError**)error;
- (BOOL)removeEntitiesWithConditions:(NSArray *)condition
                   entityDescription:(NSEntityDescription *)entityDescription 
                                save:(BOOL)save 
                               count:(NSUInteger)count 
                              offset:(NSUInteger)offset 
                     sortDescriptors:(NSArray*)descriptors
                               error:(NSError **)error;

- (BOOL)removeEntitiesWithFetch:(NSFetchRequest*)fetchRequest
                           save:(BOOL)save 
                          error:(NSError**)error;

- (BOOL)removeEntities:(NSArray*)entities
                 error:(NSError**)error;
- (BOOL)removeEntitiesWithConditions:(NSArray*)condition
                   entityDescription:(NSEntityDescription*)entityDescription 
                               error:(NSError**)error;
- (BOOL)removeEntitiesWithPredicate:(NSPredicate*)predicate
                          error:(NSError**)error;

#pragma mark - query


// if unFaulting, properties value are fetched into memory in order to reduce round trip with persistent store
- (NSArray*)entitiesWithQuery:(NSDictionary*)query
              entityDescription:(NSEntityDescription*)entityDescription 
                          error:(NSError**)error;

- (NSArray*)entitiesWithQuery:(NSDictionary*)query
              entityDescription:(NSEntityDescription*)entityDescription 
                     unFaulting:(BOOL)unFaulting
                          error:(NSError**)error;

- (NSArray*)entitiesWithQuery:(NSDictionary*)query
              entityDescription:(NSEntityDescription*)entityDescription 
                     unFaulting:(BOOL)unFaulting
                       offset:(NSUInteger)offset
                         count:(NSUInteger)count
              sortDescriptors:(NSArray*)descriptors
                          error:(NSError**)error;

- (NSArray*)entitiesWithQueries:(NSArray*)queries
              entityDescription:(NSEntityDescription*)entityDescription 
                          error:(NSError**)error;

- (NSArray*)entitiesWithQueries:(NSArray*)queries
              entityDescription:(NSEntityDescription*)entityDescription 
                     unFaulting:(BOOL)unFaulting
                          error:(NSError**)error;

- (NSArray*)entitiesWithQueries:(NSArray*)queries
              entityDescription:(NSEntityDescription*)entityDescription 
                     unFaulting:(BOOL)unFaulting
                         offset:(NSUInteger)offset
                         count:(NSUInteger)count
                sortDescriptors:(NSArray*)descriptors
                          error:(NSError**)error;

- (NSArray*)entitiesWithEqualQueries:(NSDictionary*)equalQueries
                      lessThanQueries:(NSDictionary*)lessThanQueries
               lessThanOrEqualQueries:(NSDictionary*)lessThanOrEqualQueries
                   greaterThanQueries:(NSDictionary*)greaterThanQueries
            greaterThanOrEqualQueries:(NSDictionary*)greaterThanOrEqualQueries
                      notEqualQueries:(NSDictionary*)notEqualQueries
                    entityDescription:(NSEntityDescription*)entityDescription
                           unFaulting:(BOOL)unFaulting
                               offset:(NSUInteger)offset
                                count:(NSUInteger)count
                      sortDescriptors:(NSArray*)descriptors
                                error:(NSError**)error;;

- (NSArray*)entitiesWithFetch:(NSFetchRequest*)fetchRequest error:(NSError**)error;
- (NSArray*)entitiesWithFetch:(NSFetchRequest*)fetchRequest unFaulting:(BOOL)unFaulting error:(NSError**)error;
@end
