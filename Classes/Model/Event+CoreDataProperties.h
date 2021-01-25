//
//  Event+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 3/30/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *event_badge_background;
@property (nullable, nonatomic, retain) NSString *event_badge_color;
@property (nullable, nonatomic, retain) NSString *event_badge_text;
@property (nullable, nonatomic, retain) NSString *event_description;
@property (nullable, nonatomic, retain) NSDate *event_end_date;
@property (nullable, nonatomic, retain) NSNumber *event_id;
@property (nullable, nonatomic, retain) NSNumber *event_live;
@property (nullable, nonatomic, retain) NSString *event_name;
@property (nullable, nonatomic, retain) NSNumber *event_position;
@property (nullable, nonatomic, retain) NSDate *event_start_date;
@property (nullable, nonatomic, retain) NSString *event_streaming_url;
@property (nullable, nonatomic, retain) NSNumber *event_watching_count;
@property (nullable, nonatomic, retain) NSOrderedSet<EventAnnouncement *> *event_announcement;
@property (nullable, nonatomic, retain) NSOrderedSet<Clip *> *event_clip;
@property (nullable, nonatomic, retain) NSOrderedSet<Comment *> *event_comment;
@property (nullable, nonatomic, retain) EventGroup *event_event_group;
@property (nullable, nonatomic, retain) Pagination *event_pagination;
@property (nullable, nonatomic, retain) Thumbnail *event_poster_thumbnail;
@property (nullable, nonatomic, retain) Shareable *event_shareable;
@property (nullable, nonatomic, retain) EventStats *event_stats;
@property (nullable, nonatomic, retain) User *event_user;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)insertObject:(EventAnnouncement *)value inEvent_announcementAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEvent_announcementAtIndex:(NSUInteger)idx;
- (void)insertEvent_announcement:(NSArray<EventAnnouncement *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEvent_announcementAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEvent_announcementAtIndex:(NSUInteger)idx withObject:(EventAnnouncement *)value;
- (void)replaceEvent_announcementAtIndexes:(NSIndexSet *)indexes withEvent_announcement:(NSArray<EventAnnouncement *> *)values;
- (void)addEvent_announcementObject:(EventAnnouncement *)value;
- (void)removeEvent_announcementObject:(EventAnnouncement *)value;
- (void)addEvent_announcement:(NSOrderedSet<EventAnnouncement *> *)values;
- (void)removeEvent_announcement:(NSOrderedSet<EventAnnouncement *> *)values;

- (void)insertObject:(Clip *)value inEvent_clipAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEvent_clipAtIndex:(NSUInteger)idx;
- (void)insertEvent_clip:(NSArray<Clip *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEvent_clipAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEvent_clipAtIndex:(NSUInteger)idx withObject:(Clip *)value;
- (void)replaceEvent_clipAtIndexes:(NSIndexSet *)indexes withEvent_clip:(NSArray<Clip *> *)values;
- (void)addEvent_clipObject:(Clip *)value;
- (void)removeEvent_clipObject:(Clip *)value;
- (void)addEvent_clip:(NSOrderedSet<Clip *> *)values;
- (void)removeEvent_clip:(NSOrderedSet<Clip *> *)values;

- (void)insertObject:(Comment *)value inEvent_commentAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEvent_commentAtIndex:(NSUInteger)idx;
- (void)insertEvent_comment:(NSArray<Comment *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEvent_commentAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEvent_commentAtIndex:(NSUInteger)idx withObject:(Comment *)value;
- (void)replaceEvent_commentAtIndexes:(NSIndexSet *)indexes withEvent_comment:(NSArray<Comment *> *)values;
- (void)addEvent_commentObject:(Comment *)value;
- (void)removeEvent_commentObject:(Comment *)value;
- (void)addEvent_comment:(NSOrderedSet<Comment *> *)values;
- (void)removeEvent_comment:(NSOrderedSet<Comment *> *)values;

@end

NS_ASSUME_NONNULL_END
