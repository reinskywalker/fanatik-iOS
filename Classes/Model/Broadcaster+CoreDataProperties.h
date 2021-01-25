//
//  Broadcaster+CoreDataProperties.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Broadcaster.h"

NS_ASSUME_NONNULL_BEGIN

@interface Broadcaster (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *broad_id;
@property (nullable, nonatomic, retain) NSString *broad_name;
@property (nullable, nonatomic, retain) NSString *broad_description;
@property (nullable, nonatomic, retain) NSString *broad_status;
@property (nullable, nonatomic, retain) NSString *broad_streaming_url;
@property (nullable, nonatomic, retain) NSString *broad_title;
@property (nullable, nonatomic, retain) NSString *broad_banner_url;
@property (nullable, nonatomic, retain) NSNumber *broad_user_id;

@end

NS_ASSUME_NONNULL_END
