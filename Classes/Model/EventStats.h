//
//  EventStats.h
//  Fanatik
//
//  Created by Erick Martin on 3/17/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

NS_ASSUME_NONNULL_BEGIN

@interface EventStats : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;

@end

NS_ASSUME_NONNULL_END

#import "EventStats+CoreDataProperties.h"
