//
//  EventGroup.h
//  Fanatik
//
//  Created by Erick Martin on 3/16/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

NS_ASSUME_NONNULL_BEGIN

@interface EventGroup : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+(void)getAllEventGroupsWithAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, NSArray *eventGroupsArray))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getEventGroupWithId:(NSString *)evGrId
                   andAccessToken:(NSString *)accessToken
                          success:(void(^)(RKObjectRequestOperation *operation, EventGroup *evGroup))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

#import "EventGroup+CoreDataProperties.h"
