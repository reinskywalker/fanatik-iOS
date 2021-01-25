//
//  Pagination.m
//  Fanatik
//
//  Created by Erick Martin on 4/14/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Pagination.h"
#import "Clip.h"
#import "Contest.h"
#import "Event.h"
#import "Timeline.h"

@implementation Pagination

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"prev_page", @"prev_page",
                                       @"next_page", @"next_page",
                                       @"current_page", @"current_page",
                                       @"total_pages", @"total_page",
                                       @"total_entries", @"total_entries",
                                       @"first_url", @"first_url",
                                       @"last_url", @"last_url",
                                       @"prev_url", @"prev_url",
                                       @"next_url", @"next_url",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
