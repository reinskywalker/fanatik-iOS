//
//  ThreadStats+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadStats+functionality.h"


@implementation ThreadStats (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"thread_stats_likes", @"likes",
                                       @"thread_stats_comments", @"comments",
                                       @"thread_stats_views", @"views",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}


@end
