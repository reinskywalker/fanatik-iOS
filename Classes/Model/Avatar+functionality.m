//
//  Avatar+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Avatar+functionality.h"

@implementation Avatar (functionality)

+(RKEntityMapping *)avatarMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];

    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"avatar_original", @"original",
                                          @"avatar_thumbnail", @"thumbnail",
                                          nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    return  mappingEntity;
}

@end
