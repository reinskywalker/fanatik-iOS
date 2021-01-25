//
//  MenuIcon+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "MenuIcon+functionality.h"

@implementation MenuIcon (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"xxxhdpi", @"xxxhdpi",
                                       @"xxhdpi", @"xxhdpi",
                                       @"xhdpi", @"xhdpi",
                                       @"hdpi", @"hdpi",
                                       @"mdpi",@"mdpi",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

@end
