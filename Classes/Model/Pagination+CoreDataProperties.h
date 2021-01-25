//
//  Pagination+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 4/14/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pagination.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pagination (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *current_page;
@property (nullable, nonatomic, retain) NSString *first_url;
@property (nullable, nonatomic, retain) NSString *last_url;
@property (nullable, nonatomic, retain) NSNumber *next_page;
@property (nullable, nonatomic, retain) NSString *next_url;
@property (nullable, nonatomic, retain) NSNumber *prev_page;
@property (nullable, nonatomic, retain) NSString *prev_url;
@property (nullable, nonatomic, retain) NSNumber *total_entries;
@property (nullable, nonatomic, retain) NSNumber *total_pages;
@property (nullable, nonatomic, retain) Clip *pagination_clip;
@property (nullable, nonatomic, retain) Event *pagination_event;
@property (nullable, nonatomic, retain) Timeline *pagination_timeline;
@property (nullable, nonatomic, retain) Contest *pagination_contest_clips;
@property (nullable, nonatomic, retain) Contest *pagination_contest_user;

@end

NS_ASSUME_NONNULL_END
