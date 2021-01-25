//
//  CoverImage+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "CoverImage+functionality.h"

@implementation CoverImage (functionality)

+(RKEntityMapping *)coverImageMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"cover_image_original", @"original",
                                       @"cover_image_160", @"_160",
                                       @"cover_image_240", @"_240",
                                       @"cover_image_320", @"_320",
                                       @"cover_image_480", @"_480",
                                       @"cover_image_640", @"_640",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    return  mappingEntity;
}

@end
