//
//  Like+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 5/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Like.h"

NS_ASSUME_NONNULL_BEGIN

@interface Like (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *like_id;
@property (nullable, nonatomic, retain) NSNumber *like_likeable_id;
@property (nullable, nonatomic, retain) NSString *like_likeable_type;
@property (nullable, nonatomic, retain) NSNumber *like_liker_id;
@property (nullable, nonatomic, retain) NSString *like_liker_type;
@property (nullable, nonatomic, retain) Clip *like_clip;
@property (nullable, nonatomic, retain) User *like_user;
@property (nullable, nonatomic, retain) Notification *like_notification;

@end

NS_ASSUME_NONNULL_END
