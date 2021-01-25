//
//  ClubStats+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubStats+functionality.h"

@implementation ClubStats (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"stats_member", @"members",
                                       @"stats_thread", @"threads",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}


@end
