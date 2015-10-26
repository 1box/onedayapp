//
//  EntityBase.m
//  CoreDataTest
//
//  Created by Dianwei Hu on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SSEntityBase.h"
#import "KMModelManager.h"
#import "SSData.h"
#import "SSDataUtil.h"

@interface SSEntityBase(){
@private
    
}
@end

@implementation SSEntityBase

+ (NSArray*)primaryKeys
{
    return nil;
}

// key is storage key, value is JSON key
+ (NSDictionary*)keyMapping
{
    return nil;
}

+ (NSString*)entityName
{
    @throw [NSException exceptionWithName:SSDataExceptionName reason:@"sub class must implement entityName method" userInfo:nil];
}

+ (NSDictionary*)updateIgnoredKeys
{
    return nil;
}

// default to SQLLite
+ (NSString*)configuratonName
{
    return @"SQLLite";
}

+ (NSEntityDescription*)entityDescription
{
    return [NSEntityDescription entityForName:[self entityName] 
                       inManagedObjectContext:[[KMModelManager sharedManager] managedObjectContext]];
}

+ (id)entityWithDictionary:(NSDictionary*)dictionary
{
    id entity = [self dataEntityWithInsert:NO];
    [entity updateWithDictionary:dictionary];
    return entity;
}

+ (NSArray*)entitiesWithDataArray:(NSArray*)dataArray
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[dataArray count]];
    [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[self entityWithDictionary:obj]];
    }];
    
    return result;
}

+ (id)insertEntityWithDictionary:(NSDictionary*)dictionary
{
    return [self insertEntityWithDictionary:dictionary syncrhonizeWithStore:YES];
}

+ (id)insertEntityWithDictionary:(NSDictionary*)dictionary syncrhonizeWithStore:(BOOL)synchronize
{
    id entity = nil;
    if(synchronize)
    {
        NSArray *pks = [self primaryKeys];
        if([pks count] > 0)
        {
            NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:[pks count]];
            NSDictionary *keyMapping = [self keyMapping];
            for(NSString *storeKey in pks)
            {
                NSString *jsonKey = [keyMapping objectForKey:storeKey];
                [query setObject:[dictionary objectForKey:jsonKey] forKey:storeKey];
            }
            
            NSError *error = nil;
            NSArray *result = [[KMModelManager sharedManager] entitiesWithQuery:query
                                                              entityDescription:[self entityDescription]
                                                                     unFaulting:NO
                                                                         offset:0
                                                                          count:1
                                                                sortDescriptors:nil
                                                                          error:&error];
            if([result count] > 0)
            {
                entity = [result objectAtIndex:0];
            }
        }
    }
    
    if(!entity)
    {
        entity = [self dataEntityWithInsert:YES];
    }
    
    [entity updateWithDictionary:dictionary];
    return entity;
}

+ (NSArray*)insertEntitiesWithDataArray:(NSArray*)dataArray
{
    return [self insertEntitiesWithDataArray:dataArray syncrhonizeWithStore:YES];
}

+ (NSArray*)insertEntitiesWithDataArray:(NSArray*)dataArray syncrhonizeWithStore:(BOOL)synchronize
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[dataArray count]];
    NSError *error = nil;
    NSMutableDictionary *compareDict = nil;
    if(synchronize)
    {
        NSArray *pks = [self primaryKeys];
        NSDictionary *keyMapping = [self keyMapping];
        NSMutableArray *queries = [NSMutableArray arrayWithCapacity:[dataArray count]];
        for(NSDictionary *data in dataArray)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[pks count]];
            for(NSString *pk in pks)
            {
                NSString *jsonKey = [keyMapping objectForKey:pk];
                if([data valueForKey:jsonKey])
                {
                    [dict setObject:[data valueForKey:jsonKey] forKey:pk];
                }
                else    
                {
                    @throw [NSException exceptionWithName:SSDataExceptionName
                                                   reason:[NSString stringWithFormat:@"json data doens't have value for key:%@", jsonKey]
                                                 userInfo:nil];
                }
            }
            
            [queries addObject:dict];
        }
        
        NSArray *queryResult = [[KMModelManager sharedManager] entitiesWithQueries:queries 
                                                                 entityDescription:[self entityDescription]
                                                                        unFaulting:NO
                                                                            offset:0
                                                                             count:[queries count]
                                                                   sortDescriptors:nil
                                                                             error:&error];
        
        compareDict = [NSMutableDictionary dictionaryWithCapacity:[queryResult count]];
        
        
        
        [queryResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = [SSDataUtil compareKeyForEntity:obj];
            [compareDict setObject:obj forKey:key];
        }];
    }
    
    NSArray *pks = [self primaryKeys];
    NSDictionary *keyMapping = [self keyMapping];
    for(NSDictionary *data in dataArray)
    {
        SSEntityBase *entity = nil;
        if([compareDict count] > 0)
        {
            NSMutableDictionary *mappedData = [NSMutableDictionary dictionaryWithCapacity:[pks count]];
            for(NSString *pk in pks)
            {
                NSString *jsonKey = [keyMapping objectForKey:pk];
                if([data objectForKey:jsonKey])
                {
                    [mappedData setObject:[data objectForKey:jsonKey] forKey:pk];
                }
                else
                {
                    [mappedData setObject:@"" forKey:pk];
                }
            }
            
            NSString *compareKey = [SSDataUtil compareKeyForData:mappedData primaryKeys:pks];
            if([compareDict objectForKey:compareKey])
            {
                entity = [compareDict objectForKey:compareKey];
            }
        }
        
        if(!entity)
        {
            entity = [self dataEntityWithInsert:YES];
        }
        
        [result addObject:entity];
    }
    
    [self updateEntities:result withDataArray:dataArray];
    return result;
}


+ (void)updateEntities:(NSArray*)entities withDataArray:(NSArray*)dataArray
{
    if([entities count] != [dataArray count])
    {
        @throw [NSException exceptionWithName:SSRuntimeException
                                       reason:[NSString stringWithFormat:@"in %s, entities count is different from data array count", __PRETTY_FUNCTION__] 
                                     userInfo:nil];
    }
    
    [entities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(SSEntityBase*)obj updateWithDictionary:[dataArray objectAtIndex:idx]];
    }];
}



+ (SSEntityBase *)dataEntityWithInsert:(BOOL)insert
{
    return [[[self class] alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext: insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
}

+ (void)updateEntity:(SSEntityBase*)entity withData:(NSDictionary*)dataDict
{
    NSDictionary *keymapping = [self keyMapping];
    NSArray *ignoredKeys = [[self updateIgnoredKeys] allKeys];
    for(NSString *storeKey in keymapping)
    {
        if([dataDict objectForKey:[keymapping objectForKey:storeKey]])
        {
            NSString *mapKey = [keymapping objectForKey:storeKey];
            if(![[dataDict objectForKey:mapKey] isKindOfClass:[NSNull class]])
            {
                if(![ignoredKeys containsObject:storeKey] || [entity valueForKeyPath:storeKey] == nil || [[entity valueForKeyPath:storeKey] isEqual: [[self updateIgnoredKeys] objectForKey:storeKey]])
                {
                    id val =[dataDict objectForKey:mapKey];
                    //修改支持data
                    if ([val isKindOfClass:[NSArray class]] || [val isKindOfClass:[NSDictionary class]]) {
                        val = [NSKeyedArchiver archivedDataWithRootObject:val];
                    }
                    [entity setValue:val forKeyPath:storeKey];
                }
            }
        }
    }
}

- (void)updateWithDictionary:(NSDictionary*)dataDict
{
    [[self class] updateEntity:self withData:dataDict];
}

@end
