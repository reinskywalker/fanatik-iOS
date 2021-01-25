//
//  EventGroup.m
//  Fanatik
//
//  Created by Erick Martin on 3/16/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "EventGroup.h"
#import "Event.h"

typedef enum{
    EventGroupRequestTypeGetAll = 0,
    EventGroupRequestTypeGetDetail = 1
}EventGroupRequestType;

@implementation EventGroup

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"event_group_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"event_group_id", @"id",
                                       @"event_group_name", @"name",
                                       @"event_group_description", @"description",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *eventMapping = [Event myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"live_events" toKeyPath:@"event_group_events" withMapping:eventMapping]];
        
    return mappingEntity;
    
}

#pragma mark - GET
+(void)getAllEventGroupsWithAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *eventGroupArr))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqEventGroupWithEventGroupId:@"" andRequestType:EventGroupRequestTypeGetAll withAccessToken:accessToken andPageNum:@(0) success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *eventGroupArr = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, eventGroupArr);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getEventGroupWithId:(NSString *)evGrId
            andAccessToken:(NSString *)accessToken
                   success:(void(^)(RKObjectRequestOperation *operation, EventGroup *evGroup))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqEventGroupWithEventGroupId:evGrId andRequestType:EventGroupRequestTypeGetDetail withAccessToken:accessToken andPageNum:@(0) success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        EventGroup *evGroup = result.firstObject;
        if(success){
            success(operation, evGroup);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


#pragma mark - mother of all request
+ (void)reqEventGroupWithEventGroupId:(NSString *)groupId
                     andRequestType:(EventGroupRequestType)reqType
                    withAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath;
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"";
    
    switch (reqType) {
        case EventGroupRequestTypeGetAll:{
            pathPattern = @"live-event-groups";
            keyPath = @"live_event_groups";
        }
            break;
        case EventGroupRequestTypeGetDetail:{
            pathPattern = [NSString stringWithFormat:@"live-event-groups/%@",groupId];
            keyPath = @"";
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
                
                [self reqEventGroupWithEventGroupId:groupId andRequestType:reqType withAccessToken:accessToken andPageNum:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    WRITE_LOG(operation.HTTPRequestOperation.responseString);
                    if(success){
                        success(operation, result);
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    WRITE_LOG(operation.HTTPRequestOperation.responseString);
                    if(failure){
                        failure(operation, error);
                    }
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
