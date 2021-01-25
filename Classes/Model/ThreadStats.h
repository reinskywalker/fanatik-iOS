//
//  Stats.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thread;

@interface ThreadStats : NSManagedObject

@property (nonatomic, retain) NSString * thread_stats_likes;
@property (nonatomic, retain) NSString * thread_stats_comments;
@property (nonatomic, retain) NSString * thread_stats_views;
@property (nonatomic, retain) Thread *tstats_thread;

@end
