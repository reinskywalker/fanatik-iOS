//
//  BroadcasterOnline+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 3/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BroadcasterOnline.h"

NS_ASSUME_NONNULL_BEGIN

@interface BroadcasterOnline (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *broadon_id;
@property (nullable, nonatomic, retain) NSNumber *broadon_broadcaster_id;
@property (nullable, nonatomic, retain) NSNumber *broadon_user_id;
@property (nullable, nonatomic, retain) NSString *broadon_broadcaster_name;
@property (nullable, nonatomic, retain) NSString *broadon_title;
@property (nullable, nonatomic, retain) NSString *broadon_description;
@property (nullable, nonatomic, retain) NSString *broadon_banner_url;
@property (nullable, nonatomic, retain) NSString *broadon_streaming_url;

@end

NS_ASSUME_NONNULL_END
