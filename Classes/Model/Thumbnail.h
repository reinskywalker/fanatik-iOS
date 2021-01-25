//
//  Thumbnail.h
//  Fanatik
//
//  Created by Sulistyo Wahyu on 4/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ClipGroup, Live, Video, Event;

@interface Thumbnail : NSManagedObject

@property (nonatomic, retain) NSString * thumbnail_320;
@property (nonatomic, retain) NSString * thumbnail_480;
@property (nonatomic, retain) NSString * thumbnail_640;
@property (nonatomic, retain) NSString * thumbnail_720;
@property (nonatomic, retain) NSString * thumbnail_big;
@property (nonatomic, retain) NSString * thumbnail_original;
@property (nonatomic, retain) NSString * thumbnail_small;
@property (nonatomic, retain) Live *thumbnail_live;
@property (nonatomic, retain) Video *thumbnail_video;
@property (nonatomic, retain) ClipGroup *thumbnail_clip_group;
@property (nonatomic, retain) Event *thumbnail_event_poster;

@end
