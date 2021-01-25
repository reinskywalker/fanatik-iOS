//
//  Stats+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "UserStats+functionality.h"

@implementation UserStats (functionality)

+(RKEntityMapping *)userStatsMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"user_stats_followers", @"followers",
                                       @"user_stats_following", @"followings",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
