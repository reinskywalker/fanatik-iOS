//
//  Pagination+CoreDataProperties.m
//  Fanatik
//
//  Created by Erick Martin on 4/14/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pagination+CoreDataProperties.h"

@implementation Pagination (CoreDataProperties)

@dynamic current_page;
@dynamic first_url;
@dynamic last_url;
@dynamic next_page;
@dynamic next_url;
@dynamic prev_page;
@dynamic prev_url;
@dynamic total_entries;
@dynamic total_pages;
@dynamic pagination_clip;
@dynamic pagination_event;
@dynamic pagination_timeline;
@dynamic pagination_contest_clips;
@dynamic pagination_contest_user;

@end
