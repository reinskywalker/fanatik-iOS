//
//  Mention+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 7/25/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Mention.h"

NS_ASSUME_NONNULL_BEGIN

@interface Mention (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *mention_id;
@property (nullable, nonatomic, retain) NSString *mentionable_type;
@property (nullable, nonatomic, retain) NSNumber *mentionable_id;
@property (nullable, nonatomic, retain) NSString *mentioner_type;
@property (nullable, nonatomic, retain) NSNumber *mentioner_id;
@property (nullable, nonatomic, retain) Comment *mention_comment;
@property (nullable, nonatomic, retain) Notification *mention_notification;

@end

NS_ASSUME_NONNULL_END
