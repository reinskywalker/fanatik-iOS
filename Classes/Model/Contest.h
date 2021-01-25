//
//  Contest.h
//  Fanatik
//
//  Created by Erick Martin on 4/14/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, ContestStats, ContestVideo, ContestWinners, User;

NS_ASSUME_NONNULL_BEGIN

@interface Contest : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;

+(void)getAllContestsWithAccessToken:(NSString *)accessToken
                          andPageNum:(NSNumber *)pageNum
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getContestsWithID:(NSNumber *)conID
          andAccessToken:(NSString *)accessToken
              andPageNum:(NSNumber *)pageNum
                 success:(void(^)(RKObjectRequestOperation *operation, Contest *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getContestClipsWithContestID:(NSNumber *)conID
                     andAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                 success:(void(^)(RKObjectRequestOperation *operation, Contest *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getContestUsersWithContestID:(NSNumber *)conID
                     andAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, Contest *result))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

#import "Contest+CoreDataProperties.h"
