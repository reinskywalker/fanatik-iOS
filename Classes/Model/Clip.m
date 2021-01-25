//
//  Clip.m
//  Fanatik
//
//  Created by Erick Martin on 4/19/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Clip.h"
#import "ClipCategory.h"
#import "ClipGroup.h"
#import "ClipStats.h"
#import "Comment.h"
#import "Contest.h"
#import "ContestWinners.h"
#import "Event.h"
#import "Pagination.h"
#import "Playlist.h"
#import "Shareable.h"
#import "Timeline.h"
#import "User.h"
#import "Video.h"

typedef enum{
    ClipRequestTypeGetAllClip = 0,
    ClipRequestTypeGetClipByID = 1,
    ClipRequestTypeSearchClip,
    ClipRequestTypeGetContestClips
    
}ClipRequestType;

@implementation Clip

// Insert code here to add functionality to your managed object subclass
#pragma mark - mapping
+ (RKEntityMapping *)baseMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"clip_id",
                                              nil];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"clip_id", @"id",
                                       @"clip_content", @"content",
                                       @"clip_published_at", @"published_at",
                                       @"clip_time_ago", @"time_ago",
                                       @"clip_type", @"type",
                                       @"clip_position",@"position",
                                       @"clip_liked", @"liked",
                                       @"clip_badge_text", @"badge_text",
                                       @"clip_badge_text_color", @"badge_color",
                                       @"clip_badge_bg_color", @"badge_background",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *statsMapping = [ClipStats myMapping];
    RKEntityMapping *userMapping = [User userMapping];
    RKEntityMapping *videoMapping = [Video videoMapping];
    RKEntityMapping *paginationMapping = [Pagination myMapping];
    RKEntityMapping *shareableMapping = [Shareable myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"clip_stats" withMapping:statsMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"clip_user" withMapping:userMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"video" toKeyPath:@"clip_video" withMapping:videoMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"clip_pagination" withMapping:paginationMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shareable" toKeyPath:@"clip_shareable" withMapping:shareableMapping]];
    
    return mappingEntity;
}

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [Clip baseMapping];
    RKEntityMapping *relatedClipMapping = [Clip relatedClipMapping];
    
    RKEntityMapping *commentMapping = [Comment myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"clip_comment" withMapping:commentMapping]];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"related" toKeyPath:@"clip_related_clips" withMapping:relatedClipMapping]];
    
    return mappingEntity;
}

+ (RKEntityMapping *)relatedClipMapping{
    return [Clip baseMapping];
}


#pragma mark - GET

+(void)getClipWithUserId:(NSString *)userID
           andPageNumber:(NSNumber *)pageNum
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipWithUserId:userID andClipId:nil andContestID:nil andQuery:nil pageNumber:pageNum andRequestType:ClipRequestTypeGetAllClip withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

+(void)searchClipWithQuery:(NSString *)q
             andPageNumber:(NSNumber *)pageNum
           withAccessToken:(NSString *)accessToken
                   success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipWithUserId:nil andClipId:nil andContestID:nil andQuery:q pageNumber:pageNum andRequestType:ClipRequestTypeSearchClip withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

+(void)getClipWithId:(NSNumber *)clipID andPageNumber:(NSNumber *)page
     withAccessToken:(NSString *)accessToken
             success:(void(^)(RKObjectRequestOperation *operation, Clip *object))success
             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipWithUserId:nil andClipId:clipID andContestID:nil andQuery:nil pageNumber:page andRequestType:ClipRequestTypeGetClipByID withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.firstObject);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getContestClipsWithContestID:(NSNumber *)contestID
                    withAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqClipWithUserId:nil andClipId:nil andContestID:contestID andQuery:nil pageNumber:pageNum andRequestType:ClipRequestTypeGetContestClips withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, [result array]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


#pragma mark - mother of all request
+ (void)reqClipWithUserId:(NSString *)userID
                andClipId:(NSNumber *)clipID
             andContestID:(NSNumber *)contID
                 andQuery:(NSString *)q
               pageNumber:(NSNumber *)pageNum
           andRequestType:(ClipRequestType)reqType
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
        case ClipRequestTypeGetAllClip:{
            pathPattern = [NSString stringWithFormat:@"users/%@/clips",userID];
            keyPath = @"clips";
        }
            break;
        case ClipRequestTypeGetClipByID:{
            pathPattern = [NSString stringWithFormat:@"clips/%@",clipID];
            
        }
            break;
        case ClipRequestTypeSearchClip:{
            pathPattern = @"clips/search";
            keyPath = @"clips";
            params[@"q"] = q;
        }
            break;
        case ClipRequestTypeGetContestClips:{
            keyPath = @"clips";
            requestMethod = RKRequestMethodGET;
            pathPattern = [NSString stringWithFormat:@"contests/%@/clips", contID];
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
        
        NSDictionary *headerDict = [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders];
        
        NSHTTPURLResponse *response = [[operation HTTPRequestOperation] response]; //operation is an RKObjectRequestOperation
        
        NSDictionary *headerDictionary = [response allHeaderFields];
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
                
                [self reqClipWithUserId:userID andClipId:clipID andContestID:contID andQuery:q pageNumber:pageNum andRequestType:reqType withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success){
                        success(operation, result);
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
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
