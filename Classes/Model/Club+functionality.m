//
//  Club+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Club+functionality.h"
#import "ClubStats+functionality.h"
#import "ClubMembership+functionality.h"

typedef enum{
    ClubRequestTypeList,
    ClubRequestTypeJoin,
    ClubRequestTypeLeave,
    ClubRequestTypeMyClub,
    ClubRequestTypeGetById,
    ClubRequestTypeSearch
}ClubRequestType;

@implementation Club (functionality)
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"club_id", @"id",
                                       @"club_name", @"name",
                                       @"club_description", @"description",
                                       @"club_user_id", @"user_id",
                                       @"club_active_at", @"active_at",
                                       @"club_join_message", @"join_message",
                                       @"club_avatar_url", @"avatar_url",
                                       @"club_cover_image_url", @"cover_image_url",
                                       @"club_members_count", @"members_count",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *statsMapping = [ClubStats myMapping];
    RKEntityMapping *membershipMapping = [ClubMembership myMapping];
    RKEntityMapping *userMapping = [User userMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"club_stats" withMapping:statsMapping]];

    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"membership" toKeyPath:@"club_membership" withMapping:membershipMapping]];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"club_user" withMapping:userMapping]];
    
    return mappingEntity;
}

#pragma mark - GET
+(void)getClubWithClubId:(NSString *)clubId withAccessToken:(NSString *)accessToken
                success:(void(^)(RKObjectRequestOperation *operation, Club *result))success
                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClubsWithId:clubId andPassword:nil andQuery:nil andRequestType:ClubRequestTypeGetById withAccesToken:accessToken andPageNumber:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, (Club*)result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
}

+(void)searchClubWithSearchString:(NSString *)searchStr
                 andPageNumber:(NSNumber *)pageNum
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{

    [self reqClubsWithId:nil andPassword:nil andQuery:searchStr andRequestType:ClubRequestTypeSearch withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

+(void)getClubListWithAccessToken:(NSString *)accessToken
                       pageNumber:(NSNumber *)pageNum
              success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClubsWithId:nil andPassword:nil andQuery:nil andRequestType:ClubRequestTypeList withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
}

+(void)getMyClubWithAccessToken:(NSString *)accessToken
                       pageNumber:(NSNumber *)pageNum
                          success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClubsWithId:nil andPassword:nil andQuery:nil andRequestType:ClubRequestTypeMyClub withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
}


+(void)joinClubWithID:(NSString *)clubID andAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClubsWithId:clubID andPassword:nil andQuery:nil andRequestType:ClubRequestTypeJoin withAccesToken:accessToken andPageNumber:0 success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
}

+(void)leaveClubWithID:(NSString *)clubID withAccessToken:(NSString *)accessToken
        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClubsWithId:clubID andPassword:nil andQuery:nil andRequestType:ClubRequestTypeLeave withAccesToken:accessToken andPageNumber:0 success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
}

#pragma mark - mother of all request
+ (void)reqClubsWithId:(NSString *)clubID
        andPassword:(NSString *)password
              andQuery:(NSString *)query
           andRequestType:(ClubRequestType)reqType
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
        case ClubRequestTypeList:{
            pathPattern = @"clubs";
            keyPath = @"clubs";
        }
            break;
        case ClubRequestTypeMyClub:{
            pathPattern = @"user-clubs";
            keyPath = @"clubs";
        }
            break;
        case ClubRequestTypeJoin:{
            pathPattern = [NSString stringWithFormat:@"clubs/%@/join",clubID];
            requestMethod = RKRequestMethodPATCH;
        }
            break;
        case ClubRequestTypeLeave:{
            pathPattern = [NSString stringWithFormat:@"clubs/%@/leave",clubID];
            requestMethod = RKRequestMethodDELETE;
        }
            break;
        case ClubRequestTypeGetById:{
            pathPattern = [NSString stringWithFormat:@"clubs/%@", clubID];
            requestMethod = RKRequestMethodGET;
        }
            break;
        case ClubRequestTypeSearch:{
            pathPattern = @"clubs/search";
            requestMethod = RKRequestMethodGET;
            keyPath = @"clubs";
            params[@"q"] = query;
        }
        
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

                [self reqClubsWithId:clubID andPassword:password andQuery:query andRequestType:reqType withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
