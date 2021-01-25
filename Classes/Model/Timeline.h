//
//  Timeline.h
//  Fanatik
//
//  Created by Erick Martin on 6/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Actor, Clip, Pagination, Playlist, User;

@interface Timeline : NSManagedObject

@property (nonatomic, retain) NSString * timeline_action;
@property (nonatomic, retain) NSString * timeline_description;
@property (nonatomic, retain) NSNumber * timeline_id;
@property (nonatomic, retain) NSDate * timeline_time;
@property (nonatomic, retain) NSString * timeline_time_ago;
@property (nonatomic, retain) NSString * timeline_type;
@property (nonatomic, retain) Clip *timeline_clip;
@property (nonatomic, retain) Pagination *timeline_pagination;
@property (nonatomic, retain) Playlist *timeline_playlist;
@property (nonatomic, retain) User *timeline_user;
@property (nonatomic, retain) Actor *timeline_actor;

@end
