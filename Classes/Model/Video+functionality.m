//
//  Video+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Video+functionality.h"
#import "Thumbnail+functionality.h"
#import "Resolution+functionality.h"
#import "Hls+functionality.h"

@implementation Video (functionality)

+(RKEntityMapping *)videoMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"video_id",
                                              nil];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"video_id", @"id",
                                       @"video_title", @"title",
                                       @"video_description", @"description",
                                       @"video_media_id", @"media_id",
                                       @"video_total_likes", @"total_likes",
                                       @"video_total_comments", @"total_comments",
                                       @"video_duration", @"duration",
                                       @"video_published_at", @"published_at",
                                       @"video_is_premium", @"premium",
                                       @"video_type", @"type",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    RKEntityMapping *thumbnailMapping = [Thumbnail thumbnailMapping];
    RKEntityMapping *resolutionMapping = [Resolution resolutionMapping];
    RKEntityMapping *hlsMapping = [Hls myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnails" toKeyPath:@"video_thumbnail" withMapping:thumbnailMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_video" toKeyPath:@"video_resolution" withMapping:resolutionMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"hls" toKeyPath:@"video_hls" withMapping:hlsMapping]];
    
    return mappingEntity;
}

@end
