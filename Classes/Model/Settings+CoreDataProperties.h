//
//  Settings+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 5/17/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Settings.h"

NS_ASSUME_NONNULL_BEGIN

@interface Settings (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *settings_activity;
@property (nullable, nonatomic, retain) NSNumber *settings_comment_notif;
@property (nullable, nonatomic, retain) NSNumber *settings_follow_notif;
@property (nullable, nonatomic, retain) NSNumber *settings_like_notif;
@property (nullable, nonatomic, retain) NSNumber *settings_mention_notif;
@property (nullable, nonatomic, retain) NSNumber *settings_notification;
@property (nullable, nonatomic, retain) NSNumber *settings_upload_notif;
@property (nullable, nonatomic, retain) User *settings_user;

@end

NS_ASSUME_NONNULL_END
