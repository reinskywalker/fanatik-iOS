
//
//  ThreadContent+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 4/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadContent+functionality.h"

@implementation ThreadContent (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"thread_content_html", @"html",
                                       @"thread_content_plain", @"plain",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
