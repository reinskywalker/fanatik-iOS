//
//  ThreadRestriction+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadRestriction+functionality.h"

@implementation ThreadRestriction (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"thread_restriction_open", @"open",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
