//
//  Live.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 6/1/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ClipStats, Comment, Hls, Shareable, Thumbnail;

@interface Live : NSManagedObject

@property (nonatomic, retain) NSString * live_description;
@property (nonatomic, retain) NSNumber * live_enable;
@property (nonatomic, retain) NSString * live_enable_at;
@property (nonatomic, retain) NSString * live_id;
@property (nonatomic, retain) NSNumber * live_liked;
@property (nonatomic, retain) NSNumber * live_premium;
@property (nonatomic, retain) NSString * live_title;
@property (nonatomic, retain) ClipStats *live_clip_stat;
@property (nonatomic, retain) NSOrderedSet *live_comment;
@property (nonatomic, retain) Hls *live_hls;
@property (nonatomic, retain) Shareable *live_shareable;
@property (nonatomic, retain) Thumbnail *live_thumbnail;
@property (nonatomic, retain) NSString * live_badge_text;
@property (nonatomic, retain) NSString * live_badge_bg_color;
@property (nonatomic, retain) NSString * live_badge_text_color;
@end

@interface Live (CoreDataGeneratedAccessors)

- (void)insertObject:(Comment *)value inLive_commentAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLive_commentAtIndex:(NSUInteger)idx;
- (void)insertLive_comment:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLive_commentAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLive_commentAtIndex:(NSUInteger)idx withObject:(Comment *)value;
- (void)replaceLive_commentAtIndexes:(NSIndexSet *)indexes withLive_comment:(NSArray *)values;
- (void)addLive_commentObject:(Comment *)value;
- (void)removeLive_commentObject:(Comment *)value;
- (void)addLive_comment:(NSOrderedSet *)values;
- (void)removeLive_comment:(NSOrderedSet *)values;
@end
