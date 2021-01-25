//
//  Activity.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Activity : NSManagedObject

@property (nonatomic, retain) NSNumber * activity_id;
@property (nonatomic, retain) NSString * activity_user_id;
@property (nonatomic, retain) NSString * activity_object_type;
@property (nonatomic, retain) NSString * activity_object_id;
@property (nonatomic, retain) NSDate * activity_time;
@property (nonatomic, retain) NSString * activity_time_ago;
@property (nonatomic, retain) NSString * activity_action;
@property (nonatomic, retain) NSString * activity_description;

@end
