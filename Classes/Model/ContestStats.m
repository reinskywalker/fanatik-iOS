//
//  ContestStats.m
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "ContestStats.h"
#import "Contest.h"

@implementation ContestStats

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"contest_stats_videos", @"videos",
                                       @"contest_stats_contestants", @"contestants",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    return mappingEntity;
}

@end
