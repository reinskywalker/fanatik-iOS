//
//  ClipStats.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, Live;

@interface ClipStats : NSManagedObject

@property (nonatomic, retain) NSNumber * clip_stats_comments;
@property (nonatomic, retain) NSNumber * clip_stats_likes;
@property (nonatomic, retain) NSNumber * clip_stats_views;
@property (nonatomic, retain) Clip *stats_clip;
@property (nonatomic, retain) Live *stats_live;

@end
