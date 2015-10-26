//
//  KMModelManager.m
//  OneDay
//
//  Created by Yu Tianhang on 13-1-19.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "KMModelManager.h"
#import "SSDataUtil.h"
#import "SSData.h"


@interface KMModelManager ()
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStore *persistentStore;
@end

@implementation KMModelManager

static KMModelManager *_sharedManager = nil;
+ (KMModelManager *)sharedManager
{
	@synchronized(self) {
		if (_sharedManager == nil) {
			_sharedManager = [[self alloc] init];
		}
		return _sharedManager;
	}
}

- (BOOL)saveContext:(NSError**)error
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:error]) {
            NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
#ifdef DEBUG
            abort();
#endif
            return NO;
        } 
    }
    return YES;
}

- (void)start
{
    [self moveDatabaseFileIfNecessary];
    [self persistentStoreCoordinator];
}

#pragma mark - private

- (BOOL)moveDatabaseFileIfNecessary
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kSourceStoreHasMovedUserDefaultKey"]) {
        return NO;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kSourceStoreHasMovedUserDefaultKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSURL *sourceURL = [self sourceStoreURL];
    NSURL *destinationURL = [self localStoreURL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:sourceURL.relativePath]) {
        return NO;
    }
    
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:destinationURL.relativePath]) {
        if ([fileManager isDeletableFileAtPath:destinationURL.relativePath]) {
            [fileManager removeItemAtURL:destinationURL error:&error];
        }
        
        if (error) {
            NSLog(@"an error occurs when try to remove destination url");
            return NO;
        }
    }
    
    if (![fileManager fileExistsAtPath:destinationURL.relativePath]) {
        if ([fileManager isReadableFileAtPath:sourceURL.relativePath]) {
            [fileManager copyItemAtURL:sourceURL toURL:destinationURL error:&error];
        }
        
        if (!error) {
            if ([fileManager isDeletableFileAtPath:sourceURL.relativePath]) {
                [fileManager removeItemAtURL:sourceURL error:&error];
            }
            
            if (error) {
                NSLog(@"an error occurs when try to delete source");
                return NO;
            }
        }
        else {
            NSLog(@"an error occurs when try to copy source to destination");
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

        [_managedObjectContext performBlockAndWait:^{
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DailyData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSError *error = nil;
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                               NSInferMappingModelAutomaticallyOption : @YES };
    
    self.persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                     configuration:nil
                                                                               URL:[self localStoreURL]
                                                                           options:options
                                                                             error:&error];
    
    if (!_persistentStore) {
        SSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
        abort();
#endif
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)sourceStoreURL
{
    NSURL *sourceStoreURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
                                                    stringByAppendingPathComponent:SSLogicStringNODefault(@"kDatabaseName")]];
    return sourceStoreURL;
}

- (NSURL *)localStoreURL
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:SSLogicStringNODefault(@"kDatabaseName")];
    return storeURL;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - SQL

- (BOOL)insertOrUpdateEntity:(SSEntityBase**)entity error:(NSError**)error
{
    return [self insertOrUpdateEntity:entity checkPrimaryKey:YES save:NO error:error];
}

- (BOOL)insertOrUpdateEntity:(SSEntityBase **)entity checkPrimaryKey:(BOOL)check save:(BOOL)save error:(NSError**)error
{
    if(entity)
    {
        BOOL duplicate = NO;
        SSEntityBase *retrievedEntity = nil;
        if(check)
        { 
            NSArray *pks = [[*entity class] primaryKeys];
            
            NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:[pks count]];
            [pks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [query setObject:[*entity valueForKey:obj] forKey:obj];
            }];
            
            NSArray *result = [self entitiesWithQuery:query
                                    entityDescription:[*entity entity]
                                           unFaulting:NO
                                               offset:0
                                                count:1
                                      sortDescriptors:nil
                                                error:error];
            if([result count] > 0)
            {
                duplicate = YES;
                retrievedEntity = [result objectAtIndex:0];
            }
        }
        
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if(!duplicate && ![*entity isInserted])
        {
            [managedObjectContext insertObject:*entity];
        }
        else if(*entity != retrievedEntity)
        {
            NSEntityDescription *ed = [*entity entity];
            NSArray *properties = [ed properties];
            [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [retrievedEntity setValue:[*entity valueForKey:[obj name]] forKey:[obj name]];
            }];
            
            *entity = retrievedEntity;
        }
        
        if(save)
        {
            [managedObjectContext save:error];
        }
    }
    
    return error == nil;
}

- (BOOL)insertOrUpdateEntities:(NSMutableArray *)entities checkPrimaryKey:(BOOL)check save:(BOOL)save error:(NSError**)error
{
    if(entities && [entities count] > 0)
    {
        NSMutableDictionary *compareDict = nil;
        if(check)
        {
            NSMutableArray *queries = [NSMutableArray arrayWithCapacity:[entities count]];
            SSEntityBase *entity = [entities objectAtIndex:0];
            NSArray *pks = [[entity class] primaryKeys];
            
            for(SSEntityBase *data in entities)
            {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[pks count]];
                NSDictionary *keyMapping = [[data class] keyMapping];
                for(NSString *pk in pks)
                {
                    NSString *jsonKey = [keyMapping objectForKey:pk];
                    if([data valueForKey:jsonKey])
                    {
                        [dict setObject:[data valueForKey:jsonKey] forKey:pk];
                    }
                }
                
                [queries addObject:dict];
            }
            
            NSArray *queryResult = [self entitiesWithQueries:queries
                                           entityDescription:[entity entity]
                                                  unFaulting:NO
                                                      offset:0
                                                       count:[queries count]
                                             sortDescriptors:nil
                                                       error:error];
            
            compareDict = [NSMutableDictionary dictionaryWithCapacity:[queryResult count]];
            
            [queryResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *key = [SSDataUtil compareKeyForEntity:obj];
                [compareDict setObject:obj forKey:key];
            }];
        }
        
        NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        [entities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SSEntityBase *entity = (SSEntityBase*)obj;
            NSString *compareKey = [SSDataUtil compareKeyForEntity:entity];
            SSEntityBase *retrievedEntity = [compareDict objectForKey:compareKey];
            if(retrievedEntity) // exists
            {
                NSEntityDescription *ed = [entity entity];
                NSArray *properties = [ed properties];
                
                [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [retrievedEntity setValue:[entity valueForKey:[obj name]] forKey:[obj name]];
                }];
                [replaceDict setObject:retrievedEntity forKey:[NSNumber numberWithInt:idx]];
            }
            else if(![entity isInserted])
            {
                [self.managedObjectContext insertObject:entity];
            }
        }];
        
        // replace exists
        for(NSNumber *idx in replaceDict)
        {
            [entities replaceObjectAtIndex:[idx unsignedIntValue] withObject:[replaceDict objectForKey:idx]];
        }
        
        if(save)
        {
            [self.managedObjectContext save:error];
        }
    }
    return error == nil;
}

- (BOOL)insertOrUpdateEntities:(NSMutableArray*)entities error:(NSError**)error
{
    return [self insertOrUpdateEntities:entities checkPrimaryKey:YES save:YES error:error];
}

#pragma mark - queries

- (NSArray*)entitiesWithQuery:(NSDictionary*)query
            entityDescription:(NSEntityDescription*)entityDescription 
                        error:(NSError**)error
{
    return [self entitiesWithQuery:query 
                 entityDescription:entityDescription
                        unFaulting:NO
                             error:error];
}

- (NSArray*)entitiesWithQuery:(NSDictionary*)query
            entityDescription:(NSEntityDescription*)entityDescription 
                   unFaulting:(BOOL)unFaulting
                        error:(NSError**)error
{
    return [self entitiesWithQuery:query
                 entityDescription:entityDescription
                        unFaulting:unFaulting
                            offset:0
                             count:NSUIntegerMax
                   sortDescriptors:nil
                             error:error];    
}

- (NSArray*)entitiesWithQuery:(NSDictionary*)query
            entityDescription:(NSEntityDescription*)entityDescription 
                   unFaulting:(BOOL)unFaulting
                       offset:(NSUInteger)offset
                        count:(NSUInteger)count 
              sortDescriptors:(NSArray*)descriptors
                        error:(NSError**)error
{
    return [self entitiesWithQueries: query ? [NSArray arrayWithObject:query] : nil
                   entityDescription:entityDescription
                          unFaulting:unFaulting
                              offset:offset
                               count:count
                     sortDescriptors:descriptors
                               error:error];
}


- (NSArray*)entitiesWithQueries:(NSArray*)queries
              entityDescription:(NSEntityDescription*)entityDescription 
                          error:(NSError**)error
{
    return [self entitiesWithQueries:queries 
                   entityDescription:entityDescription 
                          unFaulting:NO 
                               error:error];
}

- (NSArray*)entitiesWithQueries:(NSArray*)queries
              entityDescription:(NSEntityDescription*)entityDescription 
                     unFaulting:(BOOL)unFaulting
                          error:(NSError**)error
{
    return [self entitiesWithQueries:queries
                   entityDescription:entityDescription
                          unFaulting:unFaulting
                              offset:0 
                               count:NSUIntegerMax
                     sortDescriptors:nil
                               error:error];
}

- (NSArray*)entitiesWithQueries:(NSArray*)queries
              entityDescription:(NSEntityDescription*)entityDescription 
                     unFaulting:(BOOL)unFaulting
                         offset:(NSUInteger)offset
                          count:(NSUInteger)count
                sortDescriptors:(NSArray*)descriptors
                          error:(NSError**)error
{
    if(![NSThread isMainThread])
    {
        @throw [NSException exceptionWithName:SSRuntimeException
                                       reason:@"data method must be invoked in main thread"
                                     userInfo:nil];
    }
    
    NSMutableArray *allPredicates = [[NSMutableArray alloc] initWithCapacity:[queries count]];
    for(NSDictionary *query in queries)
    {
        NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:[query count]];
        for(NSString *key in query)
        {
            NSExpression *le = [NSExpression expressionForKeyPath:key];
            NSExpression *re = [NSExpression expressionForConstantValue:[query objectForKey:key]];
            NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le
                                                                               rightExpression:re
                                                                                      modifier:NSDirectPredicateModifier
                                                                                          type:NSEqualToPredicateOperatorType
                                                                                       options:0];
            [predicates addObject:comparePredicate];
        }
        
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [allPredicates addObject:compoundPredicate];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate = [allPredicates count] > 0 ? [NSCompoundPredicate orPredicateWithSubpredicates:allPredicates] : nil;
    [request setEntity:entityDescription];
    [request setPredicate:fetchPredicate];
    
    [request setReturnsObjectsAsFaults:!unFaulting];
    if(count != NSUIntegerMax)
    {
        [request setFetchLimit:count];
    }
    
    [request setFetchOffset:offset];
    if([descriptors count] > 0)
    {
        [request setSortDescriptors:descriptors];
    }
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    return result;
}

- (NSArray *)entitiesWithEqualQueries:(NSDictionary*)equalQueries
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
                                error:(NSError**)error
{
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:20];
    
    // equal
    for (NSString *key in equalQueries)
    {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[equalQueries objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }

    // less than
    for (NSString *key in lessThanQueries)
    {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[lessThanQueries objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSLessThanPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // less than or equal
    for (NSString *key in lessThanOrEqualQueries)
    {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[lessThanOrEqualQueries objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSLessThanOrEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }

    // greater than
    for (NSString *key in greaterThanQueries) {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[greaterThanQueries objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSGreaterThanPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // greater than or equal
    for (NSString *key in greaterThanOrEqualQueries) {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[greaterThanOrEqualQueries objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSGreaterThanOrEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // not equal
    for (NSString *key in notEqualQueries) {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[notEqualQueries objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSNotEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // compound predicates
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    // fetch
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate = compoundPredicate;
    [request setEntity:entityDescription];
    [request setPredicate:fetchPredicate];
    [request setReturnsObjectsAsFaults:!unFaulting];
    [request setFetchLimit:count];
    [request setFetchOffset:offset];
    [request setSortDescriptors:descriptors];
    
    NSError *tError = nil;
    NSArray *result = [[KMModelManager sharedManager] entitiesWithFetch:request error:&tError];
    *error = tError;
    
    if (!*error) {
        return result;
    }
    else {
        return nil;
    }
}

- (NSArray*)entitiesWithFetch:(NSFetchRequest*)fetchRequest unFaulting:(BOOL)unFaulting error:(NSError**)error
{
    [fetchRequest setReturnsObjectsAsFaults:!unFaulting];
    return [self entitiesWithFetch:fetchRequest error:error];
}

- (NSArray*)entitiesWithFetch:(NSFetchRequest *)fetchRequest error:(NSError **)error
{
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:error];
}

- (BOOL)removeEntitiesWithPredicate:(NSPredicate*)predicate error:(NSError**)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:predicate];
    [self.managedObjectContext executeFetchRequest:request error:error];
    
    return error == nil;
}

#pragma mark - remove
- (BOOL)removeEntities:(NSArray*)entities save:(BOOL)save error:(NSError**)error
{
    [entities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.managedObjectContext deleteObject:obj];
    }];
    
    if(save)
    {
        [self.managedObjectContext save:error];
    }
    
    return error == nil;
}

- (BOOL)removeEntitiesWithConditions:(NSArray *)condition
                   entityDescription:(NSEntityDescription *)entityDescription 
                                save:(BOOL)save 
                               count:(NSUInteger)count 
                              offset:(NSUInteger)offset 
                     sortDescriptors:(NSArray*)descriptors
                               error:(NSError **)error;
{
    NSArray * entities = [self entitiesWithQueries:condition entityDescription:entityDescription unFaulting:NO offset:offset count:count sortDescriptors:descriptors error:error];
    if (!error || !*error) {
        [self removeEntities:entities save:save error:error];
    }
    
    return error == nil;
}

- (BOOL)removeEntitiesWithConditions:(NSArray*)condition
                   entityDescription:(NSEntityDescription*)entityDescription 
                                save:(BOOL)save 
                               error:(NSError**)error
{
//    NSArray *entities = [self entitiesWithQueries:condition entityDescription:entityDescription error:error];
//    if(!error || !*error)
//    {
//        [self removeEntities:entities save:save error:error];
//    }
    return [self removeEntitiesWithConditions:condition entityDescription:entityDescription save:save count:NSUIntegerMax offset:0 sortDescriptors:nil error:error];
}

- (BOOL)removeEntitiesWithFetch:(NSFetchRequest*)fetchRequest
                           save:(BOOL)save 
                          error:(NSError**)error
{
    NSError *tError = nil;
    NSArray *entities = [self entitiesWithFetch:fetchRequest error:&tError];
    if(!tError)
    {
        [self removeEntities:entities save:save error:&tError];
    }
    
    if(error)
    {
        *error = tError;
    }
    
    return error == nil;
}

- (BOOL)removeEntities:(NSArray*)entities error:(NSError**)error
{
    return [self removeEntities:entities save:YES error:error];
}

- (BOOL)removeEntitiesWithConditions:(NSArray*)condition entityDescription:(NSEntityDescription*)entityDescription error:(NSError**)error
{
    return [self removeEntitiesWithConditions:condition entityDescription:entityDescription save:YES error:error];
}

- (BOOL)removeEntitiesWithFetch:(NSFetchRequest*)fetchRequest error:(NSError**)error
{
    return [self removeEntitiesWithFetch:fetchRequest save:YES error:error];
}
@end
