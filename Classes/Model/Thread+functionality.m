//
//  Thread+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Thread+functionality.h"
#import "ThreadStats+functionality.h"
#import "ThreadRestriction+functionality.h"
#import "ThreadContent+functionality.h"
typedef enum {
    ThreadRequestTypeList,
    ThreadRequestTypeShow,
    ThreadRequestTypeCreate,
    ThreadRequestTypeUpdate,
    ThreadRequestTypeDelete,
    ThreadRequestTypeReport,
    ThreadRequestTypeMy,
    ThreadRequestTypePopular,
    ThreadRequestTypeLike,
    ThreadRequestTypeUnlike
}ThreadRequestType;

@implementation Thread (functionality)


+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"thread_id",
                                              nil];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"thread_id", @"id",
                                       @"thread_club_id", @"club_id",
                                       @"thread_title", @"title",
                                       @"thread_image_url", @"image_url",
                                       @"thread_created_at", @"created_at",
                                       @"thread_time_ago", @"time_ago",
                                       @"thread_liked", @"liked",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *statsMapping = [ThreadStats myMapping];
    RKEntityMapping *userMapping = [User userMapping];
    RKEntityMapping *restrictionMapping = [ThreadRestriction myMapping];
    RKEntityMapping *contentMapping = [ThreadContent myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"thread_stats" withMapping:statsMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"restriction" toKeyPath:@"thread_restriction" withMapping:restrictionMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"thread_user" withMapping:userMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"content" toKeyPath:@"thread_content" withMapping:contentMapping]];
    
    return mappingEntity;
}

#pragma - mark - CREATE
+(void)createThreadWithClubId:(NSString *)clubID andDict:(NSDictionary *)threadDict
                attachedImage:(UIImage *)image
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:clubID andThreadId:nil andThreadDict:threadDict andMessage:nil attachedImage:image pageNumber:nil andRequestType:ThreadRequestTypeCreate withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma - mark - UPDATE
+(void)updateThreadWithId:(NSString *)threadID
            andDict:(NSDictionary *)threadDict
            attachedImage:(UIImage *)image
            withAccessToken:(NSString *)accessToken
                    success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                    failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:nil andThreadId:threadID andThreadDict:threadDict andMessage:nil attachedImage:image pageNumber:nil andRequestType:ThreadRequestTypeUpdate withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - GET

+(void)getAllThreadWithClubId:(NSString *)clubID
           andPageNumber:(NSNumber *)pageNum
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultssArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:clubID andThreadId:nil andThreadDict:nil andMessage:nil attachedImage:nil pageNumber:pageNum andRequestType:ThreadRequestTypeList withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
    
}

+(void)getThreadWithClubId:(NSString *)clubID
               andThreadId:(NSString *)threadID
                andPageNumber:(NSNumber *)pageNum
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Thread *threadObj))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:clubID andThreadId:threadID andThreadDict:nil andMessage:nil attachedImage:nil pageNumber:pageNum andRequestType:ThreadRequestTypeShow withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getUserThreadsWithPageNumber:(NSNumber *)pageNum
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:nil andThreadId:nil andThreadDict:nil andMessage:nil attachedImage:nil pageNumber:pageNum andRequestType:ThreadRequestTypeMy withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getPopularThreadWithClubId:(NSString *)clubID
                andPageNumber:(NSNumber *)pageNum
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultssArray))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:clubID andThreadId:nil andThreadDict:nil andMessage:nil attachedImage:nil pageNumber:pageNum andRequestType:ThreadRequestTypePopular withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
    
}

#pragma mark - DELETE
+(void)deleteUserThreadsWithId:(NSString *)threadID
                    withAccessToken:(NSString *)accessToken
                            success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqThreadWithClubId:nil andThreadId:threadID andThreadDict:nil andMessage:nil attachedImage:nil pageNumber:nil andRequestType:ThreadRequestTypeDelete withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - REPORT
+(void)reportUserThreadsWithId:(NSString *)threadID
                    andMessage:(NSString *)message
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:nil andThreadId:threadID andThreadDict:nil andMessage:message attachedImage:nil pageNumber:nil andRequestType:ThreadRequestTypeReport withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - LIKE / UNLIKE
+(void)likeUserThreadsWithId:(NSString *)threadID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:nil andThreadId:threadID andThreadDict:nil andMessage:nil  attachedImage:nil pageNumber:nil andRequestType:ThreadRequestTypeLike withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


+(void)unlikeUserThreadsWithId:(NSString *)threadID
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadWithClubId:nil andThreadId:threadID andThreadDict:nil andMessage:nil attachedImage:nil pageNumber:nil andRequestType:ThreadRequestTypeUnlike withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - mother of all request
+ (void)reqThreadWithClubId:(NSString *)clubID
                   andThreadId:(NSString *)threadID
           andThreadDict:(NSDictionary *)threadDict
                 andMessage:(NSString *)msg
                attachedImage:(UIImage *)image
                  pageNumber:(NSNumber *)pageNum
              andRequestType:(ThreadRequestType)reqType
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"";
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"";
    
    switch (reqType) {
        case ThreadRequestTypeList:{
            pathPattern = [NSString stringWithFormat:@"clubs/%@/threads",clubID];
            keyPath = @"threads";
        }
            break;
        case ThreadRequestTypePopular:{
            pathPattern = [NSString stringWithFormat:@"clubs/%@/popular-threads",clubID];
            keyPath = @"threads";
        }
            break;
        case ThreadRequestTypeShow:{
            pathPattern = [NSString stringWithFormat:@"clubs/%@/threads/%@",clubID,threadID];
            
        }
            break;
        case ThreadRequestTypeCreate:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"clubs/%@/threads",clubID];
            params[@"thread"] = threadDict;
            
        }
            break;
        case ThreadRequestTypeUpdate:{
            requestMethod = RKRequestMethodPATCH;
            pathPattern = [NSString stringWithFormat:@"user-threads/%@",threadID];
            params[@"thread"] = threadDict;
            
        }
            break;
        case ThreadRequestTypeMy:{
            pathPattern = @"user-threads";
            keyPath = @"threads";
            
        }
            break;
        case ThreadRequestTypeDelete:{
            requestMethod = RKRequestMethodDELETE;
            pathPattern = [NSString stringWithFormat:@"user-threads/%@", threadID];
        }
            break;
            
        case ThreadRequestTypeReport:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"threads/%@/report", threadID];
            params[@"message"] = msg;
        }
            break;
            
        case ThreadRequestTypeLike:{
            requestMethod = RKRequestMethodPATCH;
            pathPattern = [NSString stringWithFormat:@"threads/%@/like", threadID];
        }
            break;
            
        case ThreadRequestTypeUnlike:{
            requestMethod = RKRequestMethodPATCH;
            pathPattern = [NSString stringWithFormat:@"threads/%@/unlike", threadID];
        }
            break;
            
            
            
        default:
            break;
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
    if((reqType == ThreadRequestTypeCreate || reqType == ThreadRequestTypeUpdate) && image != nil){
        request = [manager multipartFormRequestWithObject:self method:requestMethod path:pathPattern parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData: UIImageJPEGRepresentation(image, 1.0)
             
                                        name:@"thread[image]"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpg"];
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
           if(statusCode == StatusCodeForbidden){
                [TheSettingsManager removeAccessToken];
                [TheSettingsManager removeSessionToken];
                [TheSettingsManager removeCurrentUserId];
                [TheSettingsManager resetSideMenuArray];
                
            }
            
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                if(statusCode == StatusCodeForbidden){
                    [TheAppDelegate logoutSuccess];
                }

                //
                [self reqThreadWithClubId:clubID andThreadId:threadID andThreadDict:threadDict andMessage:msg attachedImage:nil pageNumber:pageNum andRequestType:reqType withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success)
                        success(operation, result);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        WRITE_LOG(@"ERROR : ");
        WRITE_LOG(operation.HTTPRequestOperation.responseString);
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}

@end
