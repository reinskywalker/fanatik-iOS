//
//  EventGroup+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 3/18/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *event_group_id;
@property (nullable, nonatomic, retain) NSString *event_group_name;
@property (nullable, nonatomic, retain) NSString *event_group_description;
@property (nullable, nonatomic, retain) NSOrderedSet<Event *> *event_group_events;

@end

@interface EventGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(Event *)value inEvent_group_eventsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEvent_group_eventsAtIndex:(NSUInteger)idx;
- (void)insertEvent_group_events:(NSArray<Event *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEvent_group_eventsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEvent_group_eventsAtIndex:(NSUInteger)idx withObject:(Event *)value;
- (void)replaceEvent_group_eventsAtIndexes:(NSIndexSet *)indexes withEvent_group_events:(NSArray<Event *> *)values;
- (void)addEvent_group_eventsObject:(Event *)value;
- (void)removeEvent_group_eventsObject:(Event *)value;
- (void)addEvent_group_events:(NSOrderedSet<Event *> *)values;
- (void)removeEvent_group_events:(NSOrderedSet<Event *> *)values;

@end

NS_ASSUME_NONNULL_END
