//
//  Mention.h
//  Fanatik
//
//  Created by Erick Martin on 7/25/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Notification;

NS_ASSUME_NONNULL_BEGIN

@interface Mention : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+(RKEntityMapping *)myMapping;
@end

NS_ASSUME_NONNULL_END

#import "Mention+CoreDataProperties.h"
