//
//  ContestWinners.m
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "ContestWinners.h"
#import "Clip.h"

@implementation ContestWinners

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    mappingEntity.identificationAttributes = @[@"contest_winners_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"contest_winners_id", @"id",
                                       @"contest_winners_category", @"category",
                                       @"contest_winners_badge_url", @"badge_url",
                                       @"contest_winners_position", @"position",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clip" toKeyPath:@"contest_winners_clip" withMapping:clipMapping]];
    
    return mappingEntity;
}

@end
