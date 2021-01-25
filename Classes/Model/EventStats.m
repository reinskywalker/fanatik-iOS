//
//  EventStats.m
//  Fanatik
//
//  Created by Erick Martin on 3/17/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "EventStats.h"

@implementation EventStats

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"event_stats_comments", @"comments",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];

    return mappingEntity;
    
}
@end
