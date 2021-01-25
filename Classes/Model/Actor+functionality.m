//
//  Actor+functionality.m
//  Fanatik
//
//  Created by Erick Martin on 6/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Actor+functionality.h"

@implementation Actor (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    mappingEntity.identificationAttributes = @[@"actor_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"actor_id", @"id",
                                       @"actor_name", @"name",
                                       @"actor_email", @"email",
                                       @"actor_type", @"type",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *avatarMapping = [Avatar avatarMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"avatar" toKeyPath:@"actor_avatar" withMapping:avatarMapping]];
    

    
    return mappingEntity;
}
@end
