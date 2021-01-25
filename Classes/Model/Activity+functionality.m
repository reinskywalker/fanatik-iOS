//
//  Activity+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Activity+functionality.h"

typedef enum{
    ActivityRequestTypeGetUserActivities = 0,
}ActivityRequestType;

@implementation Activity (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"activity_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"activity_id", @"id",
                                       @"activity_user_id", @"user_id",
                                       @"activity_object_type", @"object_type",
                                       @"activity_object_id", @"object_id",
                                       @"activity_time", @"time",
                                       @"activity_action", @"action",
                                       @"activity_description", @"description",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    return mappingEntity;
    
}

#pragma mark - GET
+(void)getAllActivitiesWithUserId:(NSString *)userID
                withAccessToken:(NSString *)accessToken
                    andPageNumber:(NSNumber *)pageNum
                        success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqActivityWithUserId:userID andPageNum:pageNum andRequestType:ActivityRequestTypeGetUserActivities andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *objectArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, objectArray);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
        
    }];
}

#pragma mark - requestlogout
+ (void)reqActivityWithUserId:(NSString*)userID
                   andPageNum:(NSNumber *)pageNum
               andRequestType:(ActivityRequestType)reqType
               andAccessToken:(NSString *)accessToken
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
    if(pageNum){
        params[@"page"] = pageNum;
    }
    
    switch (reqType) {
        case ActivityRequestTypeGetUserActivities:{
            pathPattern = [NSString stringWithFormat:@"users/%@/activities",userID];
            keyPath = @"activities";
        }
            break;
            
            
        default:
            break;
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
    WRITE_LOG(@"=======================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@",SERVER_URL(), pathPattern];
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [TheAppDelegate writeLog:operation.HTTPRequestOperation.responseString];
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

                [self reqActivityWithUserId:userID andPageNum:pageNum andRequestType:reqType andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    WRITE_LOG(operation.HTTPRequestOperation.responseString);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    WRITE_LOG(operation.HTTPRequestOperation.responseString);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
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
