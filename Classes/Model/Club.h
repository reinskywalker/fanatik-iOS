//
//  Club.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@class ClubMembership;
@class ClubStats;

@interface Club : NSManagedObject

@property (nonatomic, retain) NSDate * club_active_at;
@property (nonatomic, retain) NSString * club_avatar_url;
@property (nonatomic, retain) NSString * club_cover_image_url;
@property (nonatomic, retain) NSString * club_description;
@property (nonatomic, retain) NSString * club_id;
@property (nonatomic, retain) NSString * club_join_message;
@property (nonatomic, retain) NSNumber * club_members_count;
@property (nonatomic, retain) NSString * club_name;
@property (nonatomic, retain) NSString * club_user_id;
@property (nonatomic, retain) ClubMembership *club_membership;
@property (nonatomic, retain) ClubStats *club_stats;
@property (nonatomic, retain) User *club_user;

@end
