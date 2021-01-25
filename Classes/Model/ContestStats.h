//
//  ContestStats.h
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contest;

NS_ASSUME_NONNULL_BEGIN

@interface ContestStats : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;

@end

NS_ASSUME_NONNULL_END

#import "ContestStats+CoreDataProperties.h"
