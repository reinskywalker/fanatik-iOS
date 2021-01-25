//
//  EventAnnouncement.m
//  Fanatik
//
//  Created by Erick Martin on 3/30/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "EventAnnouncement.h"
#import "Event.h"

@implementation EventAnnouncement

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"event_announcement_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"event_announcement_id", @"id",
                                       @"event_announcement_content", @"content",
                                       @"event_announcement_status", @"status",
                                       @"event_id", @"live_event_id",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    return mappingEntity;
    
}

@end
