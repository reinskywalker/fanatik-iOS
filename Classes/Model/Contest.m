//
//  Contest.m
//  Fanatik
//
//  Created by Erick Martin on 4/14/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Contest.h"
#import "Clip.h"
#import "ContestStats.h"
#import "ContestVideo.h"
#import "ContestWinners.h"
#import "User.h"

typedef enum {
    ContestRequestTypeGetAll,
    ContestRequestTypeGetDetail,
    ContestRequestTypeUpdate,
    ContestRequestTypeGetClips,
    ContestRequestTypeGetUsers
}ContestRequestType;

@implementation Contest

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    mappingEntity.identificationAttributes = @[@"contest_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"contest_id", @"id",
                                       @"contest_name", @"name",
                                       @"contest_description", @"description",
                                       @"contest_visible", @"visible",
                                       @"contest_start_time", @"start_time",
                                       @"contest_end_time", @"end_time",
                                       @"contest_avatar_url", @"avatar_url",
                                       @"contest_cover_image_url", @"cover_image_url",
                                       @"contest_expired", @"expired",
                                       @"contest_badge_text", @"badge_text",
                                       @"contest_badge_color", @"badge_color",
                                       @"contest_badge_background", @"badge_background",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clips" toKeyPath:@"contest_clips" withMapping:clipMapping]];
    
    RKEntityMapping *userMapping = [User userMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"users" toKeyPath:@"contest_user" withMapping:userMapping]];
    
    RKEntityMapping *contestWinnersMapping = [ContestWinners myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contest_winners" toKeyPath:@"contest_contest_winners" withMapping:contestWinnersMapping]];
    
    RKEntityMapping *contestVideoMapping = [ContestVideo myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"video" toKeyPath:@"contest_contest_video" withMapping:contestVideoMapping]];
    
    RKEntityMapping *contestStatsMapping = [ContestStats myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"contest_contest_stats" withMapping:contestStatsMapping]];
    
    RKEntityMapping *clipPagination = [Pagination myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"contest_clips_pagination" withMapping:clipPagination]];
    
    RKEntityMapping *userPagination = [Pagination myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"contest_user_pagination" withMapping:userPagination]];

    return mappingEntity;
}


#pragma mark - GET

+(void)getAllContestsWithAccessToken:(NSString *)accessToken
                          andPageNum:(NSNumber *)pageNum
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqContestWithRequestType:ContestRequestTypeGetAll withContestID:nil withPageNum:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        if(success)
            success(operation, [result array]);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getContestsWithID:(NSNumber *)conID
          andAccessToken:(NSString *)accessToken
              andPageNum:(NSNumber *)pageNum
                 success:(void(^)(RKObjectRequestOperation *operation, Contest *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqContestWithRequestType:ContestRequestTypeGetDetail withContestID:conID withPageNum:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        if(success)
            success(operation, [result firstObject]);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getContestClipsWithContestID:(NSNumber *)conID
                     andAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, Contest *result))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqContestWithRequestType:ContestRequestTypeGetClips withContestID:conID withPageNum:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        if(success)
            success(operation, [result firstObject]);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];


}

+(void)getContestUsersWithContestID:(NSNumber *)conID
                     andAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, Contest *result))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{

    [self reqContestWithRequestType:ContestRequestTypeGetUsers withContestID:conID withPageNum:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        if(success)
            success(operation, [result firstObject]);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


#pragma mark - mother of all request
+ (void)reqContestWithRequestType:(ContestRequestType)reqType
                    withContestID:(NSNumber *)contestID
                      withPageNum:(NSNumber *)pageNum
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
    
    NSString *pathPattern = @"contests";
    
    switch (reqType) {
        case ContestRequestTypeGetAll:{
            keyPath = @"contests";
            requestMethod = RKRequestMethodGET;
        }
            break;
        case ContestRequestTypeGetDetail:{
            keyPath = @"";
            requestMethod = RKRequestMethodGET;
            pathPattern = [NSString stringWithFormat:@"contests/%@", contestID];
        }
            break;
        case ContestRequestTypeUpdate:{
            keyPath = @"";
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"contests/%@/upload", contestID];
        }
            break;
        case ContestRequestTypeGetClips:{
            keyPath = @"";
            requestMethod = RKRequestMethodGET;
            pathPattern = [NSString stringWithFormat:@"contests/%@/clips", contestID];
        }
            break;
        case ContestRequestTypeGetUsers:{
            keyPath = @"";
            requestMethod = RKRequestMethodGET;
            pathPattern = [NSString stringWithFormat:@"contests/%@/users", contestID];
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
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                [self reqContestWithRequestType:reqType withContestID:contestID withPageNum:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
