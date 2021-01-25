//
//  User.h
//  Fanatik
//
//  Created by Erick Martin on 4/29/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const userTypeOfficial;
extern NSString *const userTypeFan;

@class Avatar, Clip, ClipGroup, Club, Comment, Contest, CoverImage, Event, Socialization, Thread, Timeline, UserStats, Notification, Settings;

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

#pragma mark - mapping
+ (RKEntityMapping *)userMapping;

#define CURRENT_USER() ([User fetchLoginUser]);
+ (User *)fetchLoginUser;

+(void)getShowUserProfileWithAccesToken:(NSString *)accessToken
                                success:(void(^)(RKObjectRequestOperation *operation, User *user))success
                                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getShowUserWithId:(NSString *)userID
           andAccesToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, User *user))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getUserFollowersForUserId:(NSString *)userId withAccesToken:(NSString *)accessToken
                   andPageNumber:(NSNumber *)pageNum
                         success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getUserFollowingForUserID:(NSString *)userID withAccesToken:(NSString *)accessToken
                   andPageNumber:(NSNumber *)pageNum
                         success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)updateProfileForUserId:(NSString *)userID
        withProfileDictionary:(NSDictionary *)profileDict
               andAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+ (void)registerWithUserDictionary:(NSDictionary *)userDict
                   withAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+ (void)loginWithUserDictionary:(NSDictionary *)userDict
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(void)logoutWithCompletion:(void(^) (NSString *message))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+(void)resetPasswordWithUserDict:(NSMutableDictionary *)userDict success:(void(^) (NSString *message))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (void)updateCoverImage:(UIImage *)image
             accessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+ (void)updateAvatarImage:(UIImage *)image
              accessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)unfollowUserWithId:(NSString *)userID andAccessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)followUserWithId:(NSString *)userID andAccessToken:(NSString *)accessToken
                success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)searchUserWithQuery:(NSString *)q withAccesToken:(NSString *)accessToken
             andPageNumber:(NSNumber *)pageNum
                   success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)searchUserAutoCompleteWithQuery:(NSString *)q withAccesToken:(NSString *)accessToken
             andPageNumber:(NSNumber *)pageNum
                   success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)changePasswordWithUserDict:(NSMutableDictionary *)userDict success:(void(^) (NSString *message))complete failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
;

+(void)registerDeviceWithSuccess:(void(^) (NSString *message))complete failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
