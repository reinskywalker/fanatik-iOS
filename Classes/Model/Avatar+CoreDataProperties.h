//
//  Avatar+CoreDataProperties.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Avatar.h"

NS_ASSUME_NONNULL_BEGIN

@interface Avatar (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar_original;
@property (nullable, nonatomic, retain) NSString *avatar_thumbnail;
@property (nullable, nonatomic, retain) Actor *avatar_actor;
@property (nullable, nonatomic, retain) User *avatar_user;
@property (nullable, nonatomic, retain) NSManagedObject *avatar_broadcaster;

@end

NS_ASSUME_NONNULL_END
