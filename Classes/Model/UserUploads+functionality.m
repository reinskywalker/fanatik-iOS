//
//  UserUploads+functionality.m
//  Fanatik
//
//  Created by Erick Martin on 6/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UserUploads+functionality.h"
#import "AWSRequestObject+functionality.h"

typedef enum {
    UserUploadsRequestTypeCreate,
    UserUploadsRequestTypeShow,
    UserUploadsRequestTypeDelete,
    UserUploadsRequestTypeUpdate,
    UserUploadsRequestTypeDone,
    UserUploadsRequestTypeCreateForEvent
}UserUploadsRequestType;

@implementation UserUploads (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    mappingEntity.identificationAttributes = @[@"user_uploads_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"user_uploads_id", @"id",
                                       @"user_uploads_user_id", @"user_id",
                                       @"user_uploads_title", @"title",
                                       @"user_uploads_description", @"description",
                                       @"user_uploads_approved", @"approved",
                                       @"user_uploads_moderated_at", @"moderated_at",
                                       @"user_uploads_rejected_reason", @"rejected_reason",
                                       @"user_uploads_video_url", @"video_url",
                                       @"user_uploads_video_thumbnail", @"video_thumbnail",
                                       @"clip_category_id", @"clip_category_id",
                                       @"user_uploads_video_uploaded", @"video_uploaded",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *awsMapping = [AWSRequestObject myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"aws_request" toKeyPath:@"user_uploads_aws" withMapping:awsMapping]];
    
    return mappingEntity;
}

#pragma mark - CREATE

+(void)createUserUploadsWithUserUploadsDictionary:(NSDictionary *)uploadDict
                                  withAccessToken:(NSString *)accessToken
                                          success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    UserUploadsRequestType uploadType = UserUploadsRequestTypeCreate;
    if(uploadDict[@"event_id"]){
        uploadType = UserUploadsRequestTypeCreateForEvent;
    }
    
    [self reqUserUploadsWithUploadDict:uploadDict videoURL:nil andRequestType:uploadType andPageNum:nil andUserUpload:nil userUploadModel:nil withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.firstObject);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)updateUserUploadsWithVideoUrl:(NSURL *)videoURL
                       andUserUpload:(UserUploads *)userUpload
                     withAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqUserUploadsWithUploadDict:nil videoURL:videoURL andRequestType:UserUploadsRequestTypeUpdate andPageNum:nil andUserUpload:userUpload userUploadModel:nil withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.firstObject);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - DONE 
+(void)doneUploadingVideoForUserUpload:(UserUploadsModel *)userUploadModel
                     withAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    
    [self reqUserUploadsWithUploadDict:nil videoURL:nil andRequestType:UserUploadsRequestTypeDone andPageNum:nil andUserUpload:nil userUploadModel:userUploadModel withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.firstObject);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - GET

+(void)getAllUserUploadsWithAccessToken:(NSString *)accessToken
                             andPageNum:(NSNumber *)pageNum
                                success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqUserUploadsWithUploadDict:nil videoURL:nil andRequestType:UserUploadsRequestTypeShow andPageNum:pageNum andUserUpload:nil userUploadModel:nil withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        if(success)
            success(operation, [result array]);

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - DELETE

+(void)deleteUserUploadsWithUserUploads:(UserUploads *)userUpload
                        withAccessToken:(NSString *)accessToken
                                success:(void(^)(RKObjectRequestOperation *operation, UserUploads *result))success
                                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqUserUploadsWithUploadDict:nil videoURL:nil andRequestType:UserUploadsRequestTypeDelete andPageNum:nil andUserUpload:userUpload userUploadModel:nil withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.firstObject);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - mother of all request
+ (void)reqUserUploadsWithUploadDict:(NSDictionary *)uploadDict
                            videoURL:(NSURL *)videoURL
                      andRequestType:(UserUploadsRequestType)reqType
                          andPageNum:(NSNumber *)pageNum
                       andUserUpload:(UserUploads *)theUserUpload
                     userUploadModel:(UserUploadsModel *)theUserUploadModel
                     withAccessToken:(NSString *)accessToken
                    success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                    failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    NSString *keyPath = nil;
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"uploads";
    
    NSNumber *contestId = [uploadDict objectForKey:@"contest_id"];
    if(contestId){
        pathPattern = [NSString stringWithFormat:@"contests/%d/upload", [contestId intValue]];
    }
    
    switch (reqType) {
        case UserUploadsRequestTypeCreateForEvent:{
            NSNumber *eventId = [uploadDict objectForKey:@"event_id"];
            pathPattern = [NSString stringWithFormat:@"live-events/%d/upload", [eventId intValue]];
            keyPath = @"";
            requestMethod = RKRequestMethodPOST;
        }
            break;
        case UserUploadsRequestTypeCreate:{
            keyPath = @"";
            requestMethod = RKRequestMethodPOST;
        }
            break;
        case UserUploadsRequestTypeShow:{
            pathPattern = @"uploads";
            keyPath = @"user_uploads";
            requestMethod = RKRequestMethodGET;
        }
            break;
        case UserUploadsRequestTypeDelete:{
            keyPath = @"";
            requestMethod = RKRequestMethodDELETE;
            pathPattern = [NSString stringWithFormat:@"uploads/%@", theUserUpload.user_uploads_id];
        }
            break;
        case UserUploadsRequestTypeUpdate:{
            keyPath = @"";
            requestMethod = RKRequestMethodPUT;
            pathPattern = [NSString stringWithFormat:@"uploads/%@", theUserUpload.user_uploads_id];
        }
            break;
        case UserUploadsRequestTypeDone:{
            keyPath = @"";
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"uploads/%@/done", theUserUploadModel.user_uploads_id];
        }
            break;
        default:
            break;
    }
    
    if(uploadDict){
        params[@"upload"] = uploadDict;
    }
    
    if(pageNum){
        params[@"page"] = pageNum;
    }
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:keyPath
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    
    if((reqType == UserUploadsRequestTypeUpdate) && videoURL != nil){
        request = [manager multipartFormRequestWithObject:self method:requestMethod path:pathPattern parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            NSArray *urlArray = [[videoURL absoluteString] componentsSeparatedByString:@"/"];
            NSString *uploadName = urlArray[urlArray.count - 1];
            
            [formData appendPartWithFileData:[NSData dataWithContentsOfURL:videoURL]
                                        name:@"upload[video]"
                                    fileName:uploadName //@"uploads.mov"
                                    mimeType:@"video/quicktime"];

        }];
    }
    
    [TheServerManager setGlobalHeaderForRequest:request];
    [manager addResponseDescriptor:responseDescriptor];
    manager.managedObjectStore = [TheDatabaseManager managedObjectStore];
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@?access_token=%@",SERVER_URL(), pathPattern, accessToken];
    
    NSString *requestType = [NSString stringWithFormat:@"req type: %@",[TheServerManager RKRequestMethodString:requestMethod]];
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        if(success){
            success(operation, result);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                //
                [self reqUserUploadsWithUploadDict:uploadDict videoURL:videoURL andRequestType:reqType andPageNum:pageNum andUserUpload:theUserUpload userUploadModel:theUserUploadModel withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success)
                        success(operation, result);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.HTTPRequestOperation.responseString);
        }
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}

+ (void)uploadVideoToS3WithURL:(NSString *)s3URL
                            videoURL:(NSURL *)videoURL
                        andUserUpload:(UserUploads *)theUserUpload
                             success:(void(^)(AFHTTPRequestOperation *operation))success
                             failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    
    RKEntityMapping *mappingEntity = [self myMapping];

    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:RKRequestMethodPUT
                                            pathPattern:@""
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://fanatikpro.s3-ap-southeast-1.amazonaws.com/"]];

    [RKMIMETypeSerialization registeredMIMETypes];
    [manager setAcceptHeaderWithMIMEType:@"text/plain"];
    [manager addResponseDescriptor:responseDescriptor];
    
    NSMutableURLRequest *request = [manager multipartFormRequestWithObject:self method:RKRequestMethodPUT path:@"test.mov?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIDG3MGI7UEGGXL5A%2F20150903%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20150903T052213Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=055429c5d16ad2ccd7682b53f81485b7c267bf0ebd9d045c34660a5c57043994" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSArray *urlArray = [[videoURL absoluteString] componentsSeparatedByString:@"/"];
        NSString *uploadName = urlArray[urlArray.count - 1];
        
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:videoURL]
                                    name:@"video"
                                fileName:uploadName
                                mimeType:@"video/quicktime"];
        
    }];
    
    
    

    WRITE_LOG(@"============================");

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (upload ke s3)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        if(success){
            success(operation);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
        
        NSLog(@"status code : %lu",(unsigned long)statusCode);
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (upload ke s3)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.responseString);
        }
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}

+ (void)toUploadVideoToS3WithURL:(NSString *)s3URL
                      videoURL:(NSURL *)videoURL
                 andUserUpload:(UserUploads *)theUserUpload
                       success:(void(^)(RKObjectRequestOperation *operation))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:self method:RKRequestMethodPUT path:@"https://fanatikpro.s3-ap-southeast-1.amazonaws.com/test.mov?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIDG3MGI7UEGGXL5A%2F20150903%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20150903T052213Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=055429c5d16ad2ccd7682b53f81485b7c267bf0ebd9d045c34660a5c57043994" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSArray *urlArray = [[videoURL absoluteString] componentsSeparatedByString:@"/"];
        NSString *uploadName = urlArray[urlArray.count - 1];
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:videoURL]
                                    name:@"video"
                                fileName:uploadName
                                mimeType:@"video/quicktime"];
    }];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (upload ke s3)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        if(success){
            success(operation);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        
        NSLog(@"status code : %lu",(unsigned long)statusCode);
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (upload ke s3)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.HTTPRequestOperation.responseString);
        }
        if(failure){
            failure(operation, error);
        }
    }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started

}



@end
