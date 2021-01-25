//
//  Socialization.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/18/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Socialization : NSManagedObject

@property (nonatomic, retain) NSNumber * socialization_follower;
@property (nonatomic, retain) NSNumber * socialization_following;
@property (nonatomic, retain) User *socialization_user;

@end
