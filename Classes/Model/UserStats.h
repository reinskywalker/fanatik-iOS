//
//  UserStats.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserStats : NSManagedObject

@property (nonatomic, retain) NSNumber * user_stats_followers;
@property (nonatomic, retain) NSNumber * user_stats_following;
@property (nonatomic, retain) User *user_stats_user;

@end
