//
//  RowMenuParam+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "RowMenuParam+functionality.h"

@implementation RowMenuParam (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"rowmenuparam_id", @"id",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
