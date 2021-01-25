//
//  Notification+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 7/25/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Notification.h"

NS_ASSUME_NONNULL_BEGIN

@interface Notification (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *notification_action;
@property (nullable, nonatomic, retain) NSDate *notification_created_at;
@property (nullable, nonatomic, retain) NSNumber *notification_id;
@property (nullable, nonatomic, retain) NSString *notification_message;
@property (nullable, nonatomic, retain) NSNumber *notification_object_id;
@property (nullable, nonatomic, retain) NSString *notification_object_type;
@property (nullable, nonatomic, retain) NSDate *notification_read_at;
@property (nullable, nonatomic, retain) Clip *notification_clip;
@property (nullable, nonatomic, retain) Comment *notification_comment;
@property (nullable, nonatomic, retain) Like *notification_like;
@property (nullable, nonatomic, retain) User *notification_user;
@property (nullable, nonatomic, retain) Mention *notification_mention;

@end

NS_ASSUME_NONNULL_END
