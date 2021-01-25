//
//  Comment+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 7/25/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *comment_content;
@property (nullable, nonatomic, retain) NSDate *comment_created_at;
@property (nullable, nonatomic, retain) NSNumber *comment_id;
@property (nullable, nonatomic, retain) NSString *comment_time_ago;
@property (nullable, nonatomic, retain) NSString *comment_type;
@property (nullable, nonatomic, retain) Clip *comment_clip;
@property (nullable, nonatomic, retain) Event *comment_event;
@property (nullable, nonatomic, retain) Live *comment_live;
@property (nullable, nonatomic, retain) Notification *comment_notification;
@property (nullable, nonatomic, retain) User *comment_user;
@property (nullable, nonatomic, retain) Mention *comment_mention;

@end

NS_ASSUME_NONNULL_END
