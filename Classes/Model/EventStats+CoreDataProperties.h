//
//  EventStats+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 3/17/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventStats.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventStats (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *event_stats_comments;
@property (nullable, nonatomic, retain) Event *stats_event;

@end

NS_ASSUME_NONNULL_END
