//
//  Socialization+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Socialization+functionality.h"

@implementation Socialization (functionality)

+(RKEntityMapping *)socializationMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"socialization_follower", @"follower",
                                       @"socialization_following", @"following",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;

}

@end
