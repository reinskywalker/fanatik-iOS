//
//  Thread+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Thread.h"

@interface Thread (functionality)

+(RKEntityMapping *)myMapping;


+(void)createThreadWithClubId:(NSString *)clubID andDict:(NSDictionary *)threadDict
            attachedImage:(UIImage *)image
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(void)updateThreadWithId:(NSString *)threadID andDict:(NSDictionary *)threadDict
            attachedImage:(UIImage *)image
          withAccessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

#pragma mark - GET

+(void)getAllThreadWithClubId:(NSString *)clubID
                andPageNumber:(NSNumber *)pageNum
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getThreadWithClubId:(NSString *)clubID
               andThreadId:(NSString *)threadID
             andPageNumber:(NSNumber *)pageNum
           withAccessToken:(NSString *)accessToken
                   success:(void(^)(RKObjectRequestOperation *operation, Thread *threadObj))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getUserThreadsWithPageNumber:(NSNumber *)pageNum
                    withAccessToken:(NSString *)accessToken
                            success:(void(^)(RKObjectRequestOperation *operation, NSArray *threadsArray))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getPopularThreadWithClubId:(NSString *)clubID
                    andPageNumber:(NSNumber *)pageNum
                  withAccessToken:(NSString *)accessToken
                          success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultssArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)reportUserThreadsWithId:(NSString *)threadID
                    andMessage:(NSString *)message
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)deleteUserThreadsWithId:(NSString *)threadID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;


+(void)unlikeUserThreadsWithId:(NSString *)threadID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)likeUserThreadsWithId:(NSString *)threadID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
