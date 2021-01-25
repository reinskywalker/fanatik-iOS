//
//  ThreadComment+functionality.m
//  Fanatik
//
//  Created by Jefry Da Gucci on 4/1/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadComment+functionality.h"

typedef enum {
    ThreadCommentRequestTypeGet,
    ThreadCommentRequestTypePost,
    ThreadCommentRequestTypeUpdate,
    ThreadCommentRequestTypeDelete,
    ThreadCommentRequestTypeReport,
    ThreadCommentRequestTypePostStickerComment
}ThreadCommentRequestType;

@implementation ThreadComment (functionality)


+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = @{
                                        @"position": @"thread_comment_position",
                                        @"id": @"thread_comment_id",
                                        @"commentable_type": @"thread_comment_commentable_type",
                                        @"commentable_id": @"thread_comment_commentable_id",
                                        @"content": @"thread_comment_content",
                                        @"created_at": @"thread_comment_created_at",
                                        @"time_ago": @"thread_comment_time_ago"
                                        }.mutableCopy;
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *mappingUser = [User userMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"thread_comment_user" withMapping:mappingUser]];
    
    
    return mappingEntity;
}

#pragma mark - GET request
+(void)getThreadCommentsWithThreadId:(NSString *)threadID
                andPageNumber:(NSNumber *)pageNum
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadCommentWithThreadId:threadID andCommentId:nil andComment:nil andMessage:nil pageNumber:pageNum andRequestType:ThreadCommentRequestTypeGet withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
    
}

#pragma - mark - CREATE
+(void)createThreadCommentWithThreadId:(NSString *)threadID
                            andComment:(NSString *)comment
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, ThreadComment *result))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadCommentWithThreadId:threadID andCommentId:nil andComment:comment andMessage:nil pageNumber:nil andRequestType:ThreadCommentRequestTypePost withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)createThreadCommentWithThreadId:(NSString *)threadID
                            andStickerId:(NSString *)stickerId
                       withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, ThreadComment *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadCommentWithThreadId:threadID andCommentId:nil andComment:stickerId andMessage:nil pageNumber:nil andRequestType:ThreadCommentRequestTypePostStickerComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma - mark - UPDATE
+(void)updateThreadCommentWithThreadId:(NSString *)threadID
                          andCommentId:(NSString *)commentID
                  andComment:(NSString *)comment
          withAccessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, Thread *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqThreadCommentWithThreadId:threadID andCommentId:commentID andComment:comment andMessage:nil pageNumber:nil andRequestType:ThreadCommentRequestTypeUpdate withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma mark - DELETE
+(void)deleteThreadCommentWithThreadId:(NSString *)threadID
                          andCommentId:(NSString *)commentID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, ThreadComment *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqThreadCommentWithThreadId:threadID andCommentId:commentID andComment:nil andMessage:nil pageNumber:nil andRequestType:ThreadCommentRequestTypeDelete withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, [result firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma mark - REPORT
+(void)reportThreadCommentWithId:(NSString *)commentID
                    andMessage:(NSString *)message
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqThreadCommentWithThreadId:nil andCommentId:commentID andComment:nil andMessage:message pageNumber:nil andRequestType:ThreadCommentRequestTypeReport withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}


#pragma mark - mother of all request
+ (void)reqThreadCommentWithThreadId:(NSString *)threadID
                andCommentId:(NSString *)commentID
              andComment:(NSString *)comment
                          andMessage:(NSString *)msg
                 pageNumber:(NSNumber *)pageNum
             andRequestType:(ThreadCommentRequestType)reqType
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
        case ThreadCommentRequestTypeGet:{
            pathPattern = [NSString stringWithFormat:@"threads/%@/comments",threadID];
            keyPath = @"comments";
        }
            break;
        case ThreadCommentRequestTypePost:{
            pathPattern = [NSString stringWithFormat:@"threads/%@/comments",threadID];
            keyPath = @"comment";
            requestMethod = RKRequestMethodPOST;
            NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"content", nil];
            params[@"comment"] = contentDict;
        }
            break;
        case ThreadCommentRequestTypePostStickerComment:{
            pathPattern = [NSString stringWithFormat:@"threads/%@/sticker-comments",threadID];
            keyPath = @"comment";
            requestMethod = RKRequestMethodPOST;
            NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"content", nil];
            params[@"comment"] = contentDict;
        }
            break;
        case ThreadCommentRequestTypeUpdate:{
            pathPattern = [NSString stringWithFormat:@"threads/%@/comments/%@",threadID, commentID];
            requestMethod = RKRequestMethodPUT;
            keyPath = @"comment";
            NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"content", nil];
            params[@"comment"] = contentDict;
        }
            break;
        case ThreadCommentRequestTypeDelete:{
            pathPattern = [NSString stringWithFormat:@"threads/%@/comments/%@",threadID, commentID];
            requestMethod = RKRequestMethodDELETE;
            keyPath = @"comment";
        }
            break;
        case ThreadCommentRequestTypeReport:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"comments/%@/report",threadID];
            params[@"message"] = msg;
            
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
                [self reqThreadCommentWithThreadId:threadID andCommentId:commentID andComment:comment andMessage:msg pageNumber:pageNum andRequestType:reqType withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
