//
//  Comment.h
//  Fanatik
//
//  Created by Erick Martin on 5/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, Event, Live, Notification, User, Mention;

NS_ASSUME_NONNULL_BEGIN

@interface Comment : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;

+(void)postCommentWithClipId:(NSNumber *)clipID andCommentContent:(NSString *)content
               andTaggedUser:(NSArray *)userArray
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)postCommentWithClipId:(NSNumber *)clipID andStickerId:(NSString *)stickerId
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)postCommentWithLiveId:(NSNumber *)clipID andCommentContent:(NSString *)comment
               andTaggedUser:(NSArray *)userArray
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)postCommentWithLiveId:(NSNumber *)liveID andStickerId:(NSString *)stickerId
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)postCommentWithEventId:(NSNumber *)evntId andCommentContent:(NSString *)comment
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(void)postCommentWithEventId:(NSNumber *)evntId andStickerId:(NSString *)stickerId
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)deleteCommentWithClipId:(NSNumber *)clipID andCommentId:(NSNumber *)commentID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)deleteCommentWithLiveId:(NSNumber *)clipID andCommentId:(NSNumber *)commentID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)deleteCommentWithEventId:(NSNumber *)evntId andCommentId:(NSNumber *)commentID
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
-(NSString*)dateString;

+(Comment *)initWithJSONString:(NSString *)JSONString;

@end

NS_ASSUME_NONNULL_END

#import "Comment+CoreDataProperties.h"
