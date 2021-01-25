//
//  EventAnnouncement+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 3/30/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventAnnouncement.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventAnnouncement (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *event_announcement_id;
@property (nullable, nonatomic, retain) NSString *event_announcement_content;
@property (nullable, nonatomic, retain) NSString *event_announcement_status;
@property (nullable, nonatomic, retain) NSNumber *event_id;
@property (nullable, nonatomic, retain) Event *event_announcement_event;

@end

NS_ASSUME_NONNULL_END
