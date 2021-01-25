//
//  Live+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Live+functionality.h"
#import "Thumbnail+functionality.h"
#import "Shareable+functionality.h"
#import "ClipStats+functionality.h"
#import "Hls+functionality.h"

typedef enum{
    LiveRequestTypeGetAllLive = 0,
    LiveRequestTypeGetLiveByID = 1,
}LiveRequestType;

@implementation Live (functionality)

+(RKEntityMapping *)baseMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"live_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"live_id", @"id",
                                       @"live_title", @"title",
                                       @"live_description", @"description",
                                       @"live_enable_at", @"enable_at",
                                       @"live_enable", @"enable",
                                       @"live_liked", @"liked",
                                       @"live_premium", @"premium",
                                       @"live_badge_text", @"badge_text",
                                       @"live_badge_text_color", @"badge_color",
                                       @"live_badge_bg_color", @"badge_background",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *thumbnailMapping = [Thumbnail thumbnailMapping];
    RKEntityMapping *hlsMapping = [Hls myMapping];
    RKEntityMapping *clipStatMapping = [ClipStats myMapping];
    RKEntityMapping *shareableMapping = [Shareable myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnails" toKeyPath:@"live_thumbnail" withMapping:thumbnailMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"hls" toKeyPath:@"live_hls" withMapping:hlsMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"live_clip_stat" withMapping:clipStatMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shareable" toKeyPath:@"live_shareable" withMapping:shareableMapping]];
    
    return mappingEntity;
}

+(RKEntityMapping *)myMapping{
    
    RKEntityMapping *mappingEntity = [Live baseMapping];
    RKEntityMapping *commentMapping = [Comment myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"live_comment" withMapping:commentMapping]];
    return mappingEntity;
}

#pragma mark - GET

+(void)getAllLivewithAccessToken:(NSString *)accessToken
                   andPageNumber:(NSNumber *)page
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqLiveWithLiveId:@"" andPageNumber:page andRequestType:LiveRequestTypeGetAllLive andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *objectArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, objectArray);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getLiveWithLiveId:(NSString *)liveID
           andPageNumber:(NSNumber *)page
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, Live *object))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqLiveWithLiveId:liveID andPageNumber:page andRequestType:LiveRequestTypeGetLiveByID andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, [result firstObject]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


#pragma mark - mother of all request
+ (void)reqLiveWithLiveId:(NSString *)liveID
            andPageNumber:(NSNumber *)page
        andRequestType:(LiveRequestType)reqType
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
    
    switch (reqType) {
        case LiveRequestTypeGetAllLive:{
            pathPattern = @"live";
            keyPath = @"lives";
        }
            break;
        case LiveRequestTypeGetLiveByID:{
            pathPattern = [NSString stringWithFormat:@"live/%@",liveID];
        }
            break;
            
        default:
            break;
    }
    
    if(page){
        params[@"page"] = page;
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
                [self reqLiveWithLiveId:liveID andPageNumber:page andRequestType:reqType andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
