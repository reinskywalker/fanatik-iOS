//
//  Thumbnail+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Thumbnail+functionality.h"

@implementation Thumbnail (functionality)

+(RKEntityMapping *)thumbnailMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"thumbnail_original", @"original",
                                       @"thumbnail_big", @"big",
                                       @"thumbnail_small", @"small",
                                       @"thumbnail_720", @"_720",
                                       @"thumbnail_640", @"_640",
                                       @"thumbnail_480", @"_480",
                                       @"thumbnail_320", @"_320",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    return mappingEntity;
}

@end
