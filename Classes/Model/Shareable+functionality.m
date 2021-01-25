//
//  Shareable+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Shareable+functionality.h"

@implementation Shareable (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"shareable_url", @"url",
                                       @"shareable_content", @"content",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
