//
//  ClubMembership+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubMembership+functionality.h"

@implementation ClubMembership (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"membership_joined", @"joined",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
