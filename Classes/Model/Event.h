//
//  Event.h
//  Fanatik
//
//  Created by Erick Martin on 3/16/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EventGroup.h"
#import "EventStats.h"
#import "EventAnnouncement.h"

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(void)getEventDetailWithId:(NSNumber *)evId withPageNumber:(NSNumber *)pageNum
             andAccessToken:(NSString *)accessToken
                    success:(void(^)(RKObjectRequestOperation *operation, Event *eventObject))success
                    failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(RKEntityMapping *)baseMapping;
+(RKEntityMapping *)myMapping;

-(NSString *)eventDateWithTimezone;
@end

NS_ASSUME_NONNULL_END

#import "Event+CoreDataProperties.h"
