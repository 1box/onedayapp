//
//  SaveTagsManager.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-2.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TagManager.h"
#import "KMModelManager.h"
#import "TagData.h"

@implementation TagManager

static TagManager *_sharedManager;
+ (TagManager *)sharedManager
{
    @synchronized(self) {
        if (_sharedManager == nil) {
            _sharedManager = [[TagManager alloc] init];
        }
    }
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - public

- (void)loadDefaultTagsFromPlist
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultTags" ofType:@"plist"];
    if (path) {
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *defaultTags = [root objectForKey:@"DefaultTags"];
        
        NSMutableArray *tags = [NSMutableArray array];
        for (id obj in defaultTags) {
            if ([obj isKindOfClass:[NSString class]]) {
                [tags addObject:@{@"name" : obj}];
            }
            else if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tagDict = obj;
                NSString *rootTag = [tagDict.allKeys objectAtIndex:0];
                [tags addObject:@{@"name" : rootTag}];
                
                for (NSString *tag in [tagDict.allValues objectAtIndex:0]) {
                    [tags addObject:
                     @{@"name" : tag,
                     @"level" : @1,
                     @"superTag" : rootTag,
                     }];
                }
            }
        }
        
        [TagData insertEntitiesWithDataArray:tags];
        [[KMModelManager sharedManager] saveContext:nil];
    }
}

- (NSArray *)tags
{
    NSError *error = nil;
    
    NSArray *result = [[KMModelManager sharedManager] entitiesWithQuery:nil
                                                      entityDescription:[TagData entityDescription]
                                                             unFaulting:NO
                                                                 offset:0
                                                                  count:NSUIntegerMax
                                                        sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]]
                                                                  error:&error];
    
    if (!error) {
        return result;
    }
    else {
        return nil;
    }
}

@end
