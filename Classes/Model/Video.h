//
//  Video.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/25/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, Hls, Resolution, Thumbnail;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * video_description;
@property (nonatomic, retain) NSString * video_duration;
@property (nonatomic, retain) NSNumber * video_id;
@property (nonatomic, retain) NSNumber * video_is_premium;
@property (nonatomic, retain) NSString * video_media_id;
@property (nonatomic, retain) NSDate * video_published_at;
@property (nonatomic, retain) NSString * video_title;
@property (nonatomic, retain) NSNumber * video_total_comments;
@property (nonatomic, retain) NSNumber * video_total_likes;
@property (nonatomic, retain) NSString * video_type;
@property (nonatomic, retain) NSSet *video_clip;
@property (nonatomic, retain) Resolution *video_resolution;
@property (nonatomic, retain) Thumbnail *video_thumbnail;
@property (nonatomic, retain) Hls *video_hls;
@end

@interface Video (CoreDataGeneratedAccessors)

- (void)addVideo_clipObject:(Clip *)value;
- (void)removeVideo_clipObject:(Clip *)value;
- (void)addVideo_clip:(NSSet *)values;
- (void)removeVideo_clip:(NSSet *)values;

@end
