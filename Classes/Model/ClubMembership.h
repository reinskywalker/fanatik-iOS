//
//  ClubMembership.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Club;

@interface ClubMembership : NSManagedObject

@property (nonatomic, retain) NSNumber * membership_joined;
@property (nonatomic, retain) Club *membership_club;

@end
