//
//  Timeline+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Timeline+functionality.h"
#import "Clip.h"
#import "Playlist+functionality.h"

typedef enum{
    TimelineRequestTypeGet = 0,
}TimelineRequestType;

@implementation Timeline (functionality)


#pragma mark - mapping
+ (RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"timeline_id",
                                              nil];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"timeline_id", @"id",
                                       @"timeline_description", @"description",
                                       @"timeline_time", @"time",
                                       @"timeline_time_ago", @"time_ago",
                                       @"timeline_type", @"resource_type",
                                       @"timeline_action", @"action",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    

    RKEntityMapping *userMapping = [User userMapping];
    RKEntityMapping *clipMapping = [Clip myMapping];
    RKEntityMapping *playlistMapping = [Playlist myMapping];
    RKEntityMapping *paginationMapping = [Pagination myMapping];
    RKEntityMapping *actorMapping = [Actor myMapping];
    
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"timeline_user" withMapping:userMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clip" toKeyPath:@"timeline_clip" withMapping:clipMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"playlist" toKeyPath:@"timeline_playlist" withMapping:playlistMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"timeline_pagination" withMapping:paginationMapping]];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"actor" toKeyPath:@"timeline_actor" withMapping:actorMapping]];
    
    return mappingEntity;
}


#pragma mark - GET


+(void)getTimelineWithAccessToken:(NSString *)accessToken
                    andPageNumber:(NSNumber *)pageNum
                          success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqTimelinewithRequestType:TimelineRequestTypeGet andPageNumber:(NSNumber*)pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}




#pragma mark - mother of all request
+ (void)reqTimelinewithRequestType:(TimelineRequestType)reqType
                     andPageNumber:(NSNumber *)pageNum
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
        case TimelineRequestTypeGet:{
            pathPattern = [NSString stringWithFormat:@"timelines"];
            keyPath = @"timelines";
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

                [self reqTimelinewithRequestType:reqType andPageNumber:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
