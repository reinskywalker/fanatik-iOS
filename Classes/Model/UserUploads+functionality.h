//
//  UserUploads+functionality.h
//  Fanatik
//
//  Created by Erick Martin on 6/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UserUploads.h"
#import "Video+functionality.h"

@interface UserUploads (functionality)

+(RKEntityMapping *)myMapping;


+(void)createUserUploadsWithUserUploadsDictionary:(NSDictionary *)uploadDict
                                  withAccessToken:(NSString *)accessToken
                                          success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getAllUserUploadsWithAccessToken:(NSString *)accessToken
                             andPageNum:(NSNumber *)pageNum
                                success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)deleteUserUploadsWithUserUploads:(UserUploads *)userUpload
                        withAccessToken:(NSString *)accessToken
                                success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)updateUserUploadsWithVideoUrl:(NSURL *)videoURL
                       andUserUpload:(UserUploads *)userUpload
                     withAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

//teguh
+ (void)uploadVideoToS3WithURL:(NSString *)s3URL
                      videoURL:(NSURL *)videoURL
                 andUserUpload:(UserUploads *)theUserUpload
                       success:(void(^)(AFHTTPRequestOperation *operation))success
                       failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (void)toUploadVideoToS3WithURL:(NSString *)s3URL
                        videoURL:(NSURL *)videoURL
                   andUserUpload:(UserUploads *)theUserUpload
                         success:(void(^)(RKObjectRequestOperation *operation))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)doneUploadingVideoForUserUpload:(UserUploadsModel *)userUploadModel
                       withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
