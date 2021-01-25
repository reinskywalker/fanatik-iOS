//
//  Thread.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 4/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ThreadContent, ThreadRestriction, ThreadStats, User;

@interface Thread : NSManagedObject

@property (nonatomic, retain) NSString * thread_club_id;
@property (nonatomic, retain) NSDate * thread_created_at;
@property (nonatomic, retain) NSString * thread_id;
@property (nonatomic, retain) NSString * thread_image_url;
@property (nonatomic, retain) NSNumber * thread_liked;
@property (nonatomic, retain) NSString * thread_time_ago;
@property (nonatomic, retain) NSString * thread_title;
@property (nonatomic, retain) ThreadRestriction *thread_restriction;
@property (nonatomic, retain) ThreadStats *thread_stats;
@property (nonatomic, retain) User *thread_user;
@property (nonatomic, retain) ThreadContent *thread_content;

@end
