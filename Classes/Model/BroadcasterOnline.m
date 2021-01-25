//
//  BroadcasterOnline.m
//  Fanatik
//
//  Created by Erick Martin on 3/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "BroadcasterOnline.h"

typedef enum{
    BroadcasterRequestTypeList = 0,
    BroadcasterRequestTypeDetail = 1
}BroadcasterRequestType;

@implementation BroadcasterOnline

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"broadon_id",
                                              nil];
    
    NSDictionary *dictEntity = @{@"id" : @"broadon_id",
                                 @"broadcaster_id" : @"broadon_broadcaster_id",
                                 @"user_id" : @"broadon_user_id",
                                 @"broadcaster_name" : @"broadon_broadcaster_name",
                                 @"title" : @"broadon_title",
                                 @"description" : @"broadon_description",
                                 @"banner_url" : @"broadon_banner_url",
                                 @"streaming_url" : @"broadon_streaming_url"};
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    return mappingEntity;
}

#pragma mark - GET
+(void)getHistoryBroadcastersListWithAccessToken:(NSString *)accessToken
                                      pageNumber:(NSNumber *)pageNum
                                  success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqBroadcasterWithId:nil andRequestType:BroadcasterRequestTypeList withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *clipsArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, clipsArray);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


#pragma mark - mother of all request
+ (void)reqBroadcasterWithId:(NSNumber *)broadID
              andRequestType:(BroadcasterRequestType)reqType
              withAccesToken:(NSString *)accessToken
               andPageNumber:(NSNumber *)pageNum
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
        case BroadcasterRequestTypeList:{
            pathPattern = @"live-chat";
            keyPath = @"broadcast_histories";
        }
            break;
        case BroadcasterRequestTypeDetail:{
            pathPattern = [NSString stringWithFormat:@"live-chat/%@",broadID];
            keyPath = @"broadcast_histories";
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
    
    [manager addResponseDescriptorsFromArray:@[responseDescriptor]];

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
                
                [self reqBroadcasterWithId:broadID andRequestType:reqType withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

@end
