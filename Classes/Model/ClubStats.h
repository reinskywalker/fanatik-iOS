//
//  ClubStats.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Club;

@interface ClubStats : NSManagedObject

@property (nonatomic, retain) NSNumber * stats_member;
@property (nonatomic, retain) NSNumber * stats_thread;
@property (nonatomic, retain) Club *stats_club;

@end
