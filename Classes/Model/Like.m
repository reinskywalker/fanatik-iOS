//
//  Like.m
//  Fanatik
//
//  Created by Erick Martin on 4/29/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Like.h"
#import "Clip.h"
#import "User.h"

@implementation Like

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"like_id", @"id",
                                       @"like_likeable_type", @"likeable_type",
                                       @"like_likeable_id", @"likeable_id",
                                       @"like_liker_type", @"liker_type",
                                       @"like_liker_id", @"liker_id",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clip" toKeyPath:@"like_clip" withMapping:clipMapping]];
    
    RKEntityMapping *userMapping = [User userMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"like_user" withMapping:userMapping]];
    
    return mappingEntity;
}

@end
