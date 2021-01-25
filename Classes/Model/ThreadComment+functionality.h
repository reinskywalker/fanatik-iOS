//
//  ThreadComment+functionality.h
//  Fanatik
//
//  Created by Jefry Da Gucci on 4/1/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadComment.h"

@interface ThreadComment (functionality)

#pragma mark - GET request
+(void)getThreadCommentsWithThreadId:(NSString *)threadID
                       andPageNumber:(NSNumber *)pageNum
                     withAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

#pragma - mark - CREATE
+(void)createThreadCommentWithThreadId:(NSString *)threadID
                            andComment:(NSString *)comment
                       withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, ThreadComment *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)createThreadCommentWithThreadId:(NSString *)threadID
                          andStickerId:(NSString *)stickerId
                       withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, ThreadComment *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

#pragma - mark - UPDATE
+(void)updateThreadCommentWithThreadId:(NSString *)threadID
                          andCommentId:(NSString *)commentID
                            andComment:(NSString *)comment
                       withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

#pragma mark - DELETE
+(void)deleteThreadCommentWithThreadId:(NSString *)threadID
                          andCommentId:(NSString *)commentID
                       withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, ThreadComment *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

#pragma mark - REPORT
+(void)reportThreadCommentWithId:(NSString *)commentID
                      andMessage:(NSString *)message
                 withAccessToken:(NSString *)accessToken
                         success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
