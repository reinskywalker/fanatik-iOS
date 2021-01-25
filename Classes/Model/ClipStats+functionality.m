//
//  ClipStats+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ClipStats+functionality.h"

typedef enum{
    ClipStatsRequestLike = 0,
    ClipStatsRequestUnlike = 1,
    ClipStatsRequestIncreaseView = 2
    
}ClipStatsRequest;

@implementation ClipStats (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"clip_stats_comments", @"comments",
                                       @"clip_stats_likes", @"likes",
                                       @"clip_stats_views", @"views",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    return mappingEntity;
}

+(ClipStats *)initWithJSONString:(NSString *)JSONString{
    NSString* MIMEType = @"application/json";
    NSError* error;
    
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:MIMEType error:&error];
    if (parsedData == nil && error) {
        //deal with error
    }
    
    //=============
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ClipStats" inManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    
    RKObjectMapping *clipStatsMapping = [self myMapping];
    
    ClipStats *clipStatsObj = [[ClipStats alloc] initWithEntity:entity insertIntoManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    RKMappingOperation* mapper = [[RKMappingOperation alloc] initWithSourceObject:parsedData[@"live"][@"stats"] destinationObject:clipStatsObj mapping:clipStatsMapping];
    [mapper performMapping:&error];
    return clipStatsObj;
}

+(void)likeClipWithId:(NSNumber *)clipID withAccessToken:(NSString *)accessToken
              success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipClipStatsWithClipId:clipID andRequestType:ClipStatsRequestLike withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)unlikeClipWithId:(NSNumber *)clipID withAccessToken:(NSString *)accessToken
              success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipClipStatsWithClipId:clipID andRequestType:ClipStatsRequestUnlike withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)increaseWatchCountForClipWithId:(NSNumber *)clipID withAccessToken:(NSString *)accessToken success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure{
    [self reqClipClipStatsWithClipId:clipID andRequestType:ClipStatsRequestIncreaseView withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - mother of all request
+ (void)reqClipClipStatsWithClipId:(NSNumber *)clipID
           andRequestType:(ClipStatsRequest)reqType
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
        case ClipStatsRequestLike:{
            pathPattern = [NSString stringWithFormat:@"clips/%@/like",clipID];
            keyPath = @"stats";
            requestMethod = RKRequestMethodPATCH;
        }
            break;
        case ClipStatsRequestUnlike:{
            pathPattern = [NSString stringWithFormat:@"clips/%@/unlike",clipID];
            keyPath = @"stats";
            requestMethod = RKRequestMethodPATCH;
        }
            break;
        case ClipStatsRequestIncreaseView:{
            pathPattern = [NSString stringWithFormat:@"clips/%@/impressions",clipID];
            keyPath = @"stats";
            requestMethod = RKRequestMethodPATCH;
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

                [self reqClipClipStatsWithClipId:clipID andRequestType:reqType withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success){
                        success(operation, result);
                    }
                    
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure){
                        failure(operation, error);
                    }
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
