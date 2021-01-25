//
//  Like.h
//  Fanatik
//
//  Created by Erick Martin on 4/29/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, User, Notification;

NS_ASSUME_NONNULL_BEGIN

@interface Like : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;
@end

NS_ASSUME_NONNULL_END

#import "Like+CoreDataProperties.h"
