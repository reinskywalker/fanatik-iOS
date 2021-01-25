//
//  Mention.m
//  Fanatik
//
//  Created by Erick Martin on 7/25/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Mention.h"
#import "Comment.h"
#import "Notification.h"

@implementation Mention

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"mention_id", @"id",
                                       @"mentionable_type", @"mentionable_type",
                                       @"mentionable_id", @"mentionable_id",
                                       @"mentioner_type", @"mentioner_type",
                                       @"mentioner_id", @"mentioner_id",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *commentMapping = [Comment myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comment" toKeyPath:@"mention_comment" withMapping:commentMapping]];
    
    return mappingEntity;
}

@end
