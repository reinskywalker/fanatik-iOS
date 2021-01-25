//
//  ContestVideo.m
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "ContestVideo.h"
#import "Contest.h"

@implementation ContestVideo

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"contest_video_url", @"url",
                                       @"contest_video_thumbnail_url", @"thumbnail",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    return mappingEntity;
}

@end
