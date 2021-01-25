//
//  User.m
//  Fanatik
//
//  Created by Erick Martin on 4/29/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "User.h"
#import "Avatar.h"
#import "Clip.h"
#import "ClipGroup.h"
#import "Club.h"
#import "Comment.h"
#import "Contest.h"
#import "CoverImage.h"
#import "Event.h"
#import "Socialization.h"
#import "Thread.h"
#import "Timeline.h"
#import "UserStats.h"

typedef enum{
    UserRequestTypeShowProfile = 0,
    UserRequestTypeUpdateProfile = 1,
    UserRequestTypeUpdateCoverImage = 2,
    UserRequestTypeUpdateAvatar = 3,
    UserRequestTypeShowUser = 4,
    UserRequestTypeGetUserFollowers = 5,
    UserRequestTypeGetUserFollowing = 6,
    UserRequestTypeFollowUser = 7,
    UserRequestTypeUnfollowUser = 8,
    UserRequestTypeSearchUser,
    UserRequestTypeChangePassword,
    UserRequestTypeSearchUserAutoComplete
}UserRequestType;

@implementation User

NSString *const userTypeOfficial = @"OfficialAccount";
NSString *const userTypeFan = @"Fan";

// Insert code here to add functionality to your managed object subclass
#pragma mark - mapping
+ (RKEntityMapping *)userMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"user_id",
                                              nil];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"user_id", @"id",
                                       @"user_email", @"email",
                                       @"user_name", @"name",
                                       @"user_info", @"info",
                                       @"user_phone", @"phone",
                                       @"user_type", @"type",
                                       @"user_username", @"username",
                                       @"user_gender", @"gender",
                                       @"user_dob", @"dob",
                                       @"user_biography", @"biography",
                                       @"user_featured", @"featured",
                                       @"user_tester", @"tester",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *statsMapping = [UserStats userStatsMapping];
    RKEntityMapping *packageMapping = [Package myMapping];
    RKEntityMapping *socializationMapping = [Socialization socializationMapping];
    RKEntityMapping *avatarMapping = [Avatar avatarMapping];
    RKEntityMapping *coverImageMapping = [CoverImage coverImageMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"user_user_stats" withMapping:statsMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"package" toKeyPath:@"user_package" withMapping:packageMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"socialization" toKeyPath:@"user_socialization" withMapping:socializationMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"avatar" toKeyPath:@"user_avatar" withMapping:avatarMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"cover_image" toKeyPath:@"user_cover_image" withMapping:coverImageMapping]];
    
    RKEntityMapping *settingsMapping = [Settings myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"setting" toKeyPath:@"user_settings" withMapping:settingsMapping]];
    
    return mappingEntity;
}

#pragma mark - GET

+(void)getShowUserProfileWithAccesToken:(NSString *)accessToken
                                success:(void(^)(RKObjectRequestOperation *operation, User *user))success
                                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqUserWithUserId:@"" andUserDictionary:nil andQuery:nil andRequestType:UserRequestTypeShowProfile withAccesToken:accessToken andPageNumber:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        User *user = [result firstObject];
        if(success){
            success(operation, user);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
    
}

+(void)getShowUserWithId:(NSString *)userID
           andAccesToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, User *user))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqUserWithUserId:userID andUserDictionary:nil andQuery:nil andRequestType:UserRequestTypeShowUser withAccesToken:accessToken andPageNumber:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        User *user = [result firstObject];
        if(success){
            success(operation, user);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
        
    }];
}


+(void)getUserFollowersForUserId:(NSString *)userId withAccesToken:(NSString *)accessToken
                   andPageNumber:(NSNumber *)pageNum
                         success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
{
    [self reqUserWithUserId:userId andUserDictionary:nil andQuery:nil andRequestType:UserRequestTypeGetUserFollowers withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *usersArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, usersArray);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
    }];
}

+(void)searchUserWithQuery:(NSString *)q withAccesToken:(NSString *)accessToken
             andPageNumber:(NSNumber *)pageNum
                   success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqUserWithUserId:nil andUserDictionary:nil andQuery:q andRequestType:UserRequestTypeSearchUser withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *usersArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, usersArray);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
    }];
}

+(void)searchUserAutoCompleteWithQuery:(NSString *)q withAccesToken:(NSString *)accessToken
                         andPageNumber:(NSNumber *)pageNum
                               success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqUserWithUserId:nil andUserDictionary:nil andQuery:q andRequestType:UserRequestTypeSearchUserAutoComplete withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *usersArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, usersArray);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
    }];
}

+(void)getUserFollowingForUserID:(NSString *)userID withAccesToken:(NSString *)accessToken
                   andPageNumber:(NSNumber *)pageNum
                         success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqUserWithUserId:userID andUserDictionary:nil andQuery:nil andRequestType:UserRequestTypeGetUserFollowing withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *usersArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, usersArray);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
    }];
    
}

#pragma mark - UPDATE
+(void)updateProfileForUserId:(NSString *)userID
        withProfileDictionary:(NSDictionary *)profileDict
               andAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqUserWithUserId:userID andUserDictionary:profileDict andQuery:nil andRequestType:UserRequestTypeUpdateProfile withAccesToken:accessToken andPageNumber:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma mark - FOLLOW
+(void)followUserWithId:(NSString *)userID andAccessToken:(NSString *)accessToken
                success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqUserWithUserId:userID andUserDictionary:nil andQuery:nil andRequestType:UserRequestTypeFollowUser withAccesToken:accessToken andPageNumber:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - UNFOLLOW
+(void)unfollowUserWithId:(NSString *)userID andAccessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqUserWithUserId:userID andUserDictionary:nil andQuery:nil andRequestType:UserRequestTypeUnfollowUser withAccesToken:accessToken andPageNumber:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
+ (void)reqUserWithUserId:(NSString *)userID
        andUserDictionary:(NSDictionary *)userDict
                 andQuery:(NSString *)q
           andRequestType:(UserRequestType)reqType
           withAccesToken:(NSString *)accessToken
            andPageNumber:(NSNumber *)pageNum
                  success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"";
    
    RKEntityMapping *mappingEntity = [self userMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"";
    
    switch (reqType) {
        case UserRequestTypeShowProfile:{
            pathPattern = @"profile";
        }
            break;
        case UserRequestTypeShowUser:{
            pathPattern = [NSString stringWithFormat:@"users/%@",userID];
        }
            break;
        case UserRequestTypeGetUserFollowers:{
            pathPattern = [NSString stringWithFormat:@"users/%@/followers",userID];
            keyPath = @"users";
        }
            break;
        case UserRequestTypeGetUserFollowing:{
            pathPattern = [NSString stringWithFormat:@"users/%@/followings",userID];
            keyPath = @"users";
        }
            break;
        case UserRequestTypeUpdateProfile:{
            requestMethod = RKRequestMethodPATCH;
            pathPattern = [NSString stringWithFormat:@"users/%@",userID];
            params[@"profile"] = userDict;
        }
            break;
        case UserRequestTypeFollowUser:{
            requestMethod = RKRequestMethodPATCH;
            pathPattern = [NSString stringWithFormat:@"users/%@/follow",userID];
        }
            break;
        case UserRequestTypeUnfollowUser:{
            requestMethod = RKRequestMethodPATCH;
            pathPattern = [NSString stringWithFormat:@"users/%@/unfollow",userID];
        }
            break;
        case UserRequestTypeSearchUser:{
            pathPattern = @"users/search";
            keyPath = @"users";
            params[@"q"] = q;
        }
            break;
        case UserRequestTypeSearchUserAutoComplete:{
            pathPattern = @"user-mentions";
            keyPath = @"users";
            params[@"q"] = q;
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
                
                [self reqUserWithUserId:userID andUserDictionary:userDict andQuery:q andRequestType:reqType withAccesToken:accessToken andPageNumber:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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



+ (User *)fetchLoginUser{
    RKManagedObjectStore *objStore = [TheDatabaseManager managedObjectStore];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([User class]) inManagedObjectContext:objStore.mainQueueManagedObjectContext]];
    [fetchRequest setIncludesPropertyValues:YES];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user_id == %@", CURRENT_USER_ID()]];
    NSError *error = nil;
    NSArray *arrResult = [objStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    return (User *)arrResult.lastObject;
}

#pragma mark - LOGIN
+ (void)loginWithUserDictionary:(NSDictionary *)userDict
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    RKEntityMapping *mappingEntity = [User userMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodPOST;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   userDict, @"user",
                                   nil];
    NSString *pathPattern = @"";
    BOOL isSocmed = userDict[@"provider"] && ![userDict[@"provider"] isEqualToString:@""]? YES : NO;
    if(isSocmed){
        pathPattern = @"auth/connect";
        
    }else{
        pathPattern = @"auth/login";
    }
    
    //Session Token Mapping
    RKEntityMapping *sessionTokenMapping = [RKEntityMapping mappingForEntityForName:@"SessionToken" inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    [sessionTokenMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             @"session_token", @"session",
                                                             nil]];
    //===
    
    //Access Token Mapping
    RKEntityMapping *accessTokenMapping = [RKEntityMapping mappingForEntityForName:@"AccessToken" inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    [accessTokenMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            @"access_token", @"token",
                                                            nil]];
    //===
    
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"user"
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [TheServerManager setGlobalHeaderForRequest:request];
    NSArray *responseDescriptorArray = [NSArray arrayWithObjects:responseDescriptor, nil];
    [manager addResponseDescriptorsFromArray:responseDescriptorArray];
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
        WRITE_LOG(@"Response : ");
        WRITE_LOG(jsonDict);
        NSString *token = jsonDict[@"access_token"][@"token"] ;
        NSString *session = jsonDict[@"session_token"][@"session"];
        
        User *userObj = [result firstObject];
        NSString *userID = userObj.user_id;
        [TheSettingsManager saveAccessToken:token];
        [TheSettingsManager saveSessionToken:session];
        [TheSettingsManager saveCurrentUserId:userID];
        if(success){
            success(operation, result);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.HTTPRequestOperation.responseString);
        }
        
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
                
                [self loginWithUserDictionary:userDict withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success)
                        success(operation, result);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if (failure) {
                        failure(operation, error);
                    }
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}

#pragma mark - LOGOUT
+(void)logoutWithCompletion:(void(^) (NSString *message))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   ACCESS_TOKEN(), @"access_token",
                                   nil];
    
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"auth/logout" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@auth/logout?access_token=%@",SERVER_URL(),ACCESS_TOKEN()];
    
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheSettingsManager removeAccessToken];
        [TheSettingsManager removeSessionToken];
        [TheSettingsManager removeCurrentUserId];
        [TheSettingsManager resetSideMenuArray];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        WRITE_LOG(@"Response String");
        WRITE_LOG(jsonDict);
        if(complete){
            complete(jsonDict[@"messages"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSUInteger statusCode = operation.response.statusCode;
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
                
                [self logoutWithCompletion:^(NSString *message) {
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    if(complete){
                        complete(jsonDict[@"messages"]);
                    }
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if(failure){
                        failure(operation, error);
                    }
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }
        
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (logout)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.responseString);
        }
        
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - REGISTER

+ (void)registerWithUserDictionary:(NSDictionary *)userDict
                   withAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    RKEntityMapping *mappingEntity = [User userMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodPOST;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   userDict, @"user",
                                   nil];
    NSString *pathPattern = @"user-registrations";
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"user"
                                            statusCodes:statusCodes];
    
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [TheServerManager setGlobalHeaderForRequest:request];
    NSArray *responseDescriptorArray = [NSArray arrayWithObjects:responseDescriptor, nil];
    [manager addResponseDescriptorsFromArray:responseDescriptorArray];
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
        WRITE_LOG(@"Response Data");
        WRITE_LOG(jsonDict);
        NSString *token = jsonDict[@"access_token"][@"token"];
        NSString *session = jsonDict[@"session_token"][@"session"];
        
        User *userObj = [result firstObject];
        NSString *userID = userObj.user_id;
        [TheSettingsManager saveAccessToken:token];
        [TheSettingsManager saveSessionToken:session];
        [TheSettingsManager saveCurrentUserId:userID];
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
                
                [self registerWithUserDictionary:userDict withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success)
                        success(operation, result);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }
        
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (register user)"];
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

#pragma mark - FORGET PASSWORD
+(void)resetPasswordWithUserDict:(NSMutableDictionary *)userDict success:(void(^) (NSString *message))complete failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   userDict, @"user",
                                   ACCESS_TOKEN(), @"access_token",
                                   nil];
    
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"auth/reset-password" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    [TheAppDelegate writeLog:[NSString stringWithFormat:@"reset password: %@",TheConstantsManager.serverURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@auth/reset-password?access_token=%@",SERVER_URL(), ACCESS_TOKEN()];
    
    NSString *requestType = @"RKRequestMethodPOST";
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        
        if(complete){
            complete(jsonDict[@"success"][@"messages"][0]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
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
                
                [self resetPasswordWithUserDict:userDict success:^(NSString *message) {
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    if(complete){
                        complete(jsonDict[@"success"][@"messages"][0]);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }
        
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (reset password)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.responseString);
        }
        
        
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - CHANGE PASSWORD
+(void)changePasswordWithUserDict:(NSMutableDictionary *)userDict success:(void(^) (NSString *message))complete failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   userDict, @"user",
                                   ACCESS_TOKEN(), @"access_token",
                                   nil];
    
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPATCH path:@"auth/change-password" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    [TheAppDelegate writeLog:[NSString stringWithFormat:@"change password: %@",TheConstantsManager.serverURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@auth/change-password?access_token=%@",SERVER_URL(), ACCESS_TOKEN()];
    
    NSString *requestType = @"RKRequestMethodPOST";
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheAppDelegate writeLog:[operation responseString]];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        if(complete){
            complete(jsonDict[@"success"][@"messages"][0]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
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
                
                [self changePasswordWithUserDict:userDict success:^(NSString *message) {
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    if(complete){
                        complete(jsonDict[@"success"][@"messages"][0]);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }
        
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (change password)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.responseString);
        }
        
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - UPDATE COVER IMAGE
+ (void)updateCoverImage:(UIImage *)image
             accessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    RKEntityMapping *mappingUser = [User userMapping];
    NSString *pathPattern = @"profile/update_cover";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKRequestMethod requsetMethod = RKRequestMethodPOST;
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingUser
                                                 method:requsetMethod
                                            pathPattern:pathPattern
                                                keyPath:@""
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableURLRequest *request = [manager multipartFormRequestWithObject:self method:requsetMethod path:pathPattern parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: UIImageJPEGRepresentation(image, 1.0)
         
                                    name:@"cover"
                                fileName:@"image.jpg"
                                mimeType:@"image/jpg"];
    }];
    [TheServerManager setGlobalHeaderForRequest:request];
    [manager addResponseDescriptor:responseDescriptor];
    
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@?access_token=%@",SERVER_URL(), pathPattern, accessToken];
    
    NSString *requestType = [NSString stringWithFormat:@"req type: %@",[TheServerManager RKRequestMethodString:requsetMethod]];
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        WRITE_LOG(@"Response");
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
                
                [self updateCoverImage:image accessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

#pragma mark - UPDATE AVATAR IMAGE
+ (void)updateAvatarImage:(UIImage *)image
              accessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    RKEntityMapping *mappingUser = [User userMapping];
    NSString *pathPattern = @"profile/update_avatar";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKRequestMethod requsetMethod = RKRequestMethodPOST;
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingUser
                                                 method:requsetMethod
                                            pathPattern:pathPattern
                                                keyPath:@""
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableURLRequest *request = [manager multipartFormRequestWithObject:self method:requsetMethod path:pathPattern parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: UIImageJPEGRepresentation(image, 1.0)
         
                                    name:@"avatar"
                                fileName:@"image.jpg"
                                mimeType:@"image/jpg"];
    }];
    [TheServerManager setGlobalHeaderForRequest:request];
    [manager addResponseDescriptor:responseDescriptor];
    
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@?access_token=%@",SERVER_URL(), pathPattern, accessToken];
    
    NSString *requestType = [NSString stringWithFormat:@"req type: %@",[TheServerManager RKRequestMethodString:requsetMethod]];
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        WRITE_LOG(@"Response");
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
                
                [self updateAvatarImage:image accessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

#pragma mark - REGISTER DEVICE
+(void)registerDeviceWithSuccess:(void(^) (NSString *message))complete failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSLog(@"Device token = %@", TheSettingsManager.deviceToken);
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSMutableDictionary *deviceDict = [NSMutableDictionary dictionary];
    deviceDict[@"key"] = TheSettingsManager.deviceToken ? TheSettingsManager.deviceToken : @"";
    deviceDict[@"imei"] = @"";
    deviceDict[@"msisdn"] = @"";
    deviceDict[@"os"] = @"ios";
    deviceDict[@"os_version"] = SYSTEM_VERSION;
    deviceDict[@"app_version"] = infoDictionary[@"CFBundleShortVersionString"] ? infoDictionary[@"CFBundleShortVersionString"] : @"";
    deviceDict[@"resolution_height"] = @([UIScreen mainScreen].bounds.size.height);
    deviceDict[@"resolution_width"] = @([UIScreen mainScreen].bounds.size.width);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   ACCESS_TOKEN(), @"access_token",
                                   deviceDict, @"device",
                                   nil];
    
    
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"mobile-devices/register" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    [TheAppDelegate writeLog:[NSString stringWithFormat:@"register device: %@",TheConstantsManager.serverURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@mobile-device/register?access_token=%@",SERVER_URL(), ACCESS_TOKEN()];
    
    NSString *requestType = @"RKRequestMethodPost";
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheAppDelegate writeLog:[operation responseString]];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        if(complete){
            complete(jsonDict[@"messages"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSUInteger statusCode = operation.response.statusCode;
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
                
                [self registerDeviceWithSuccess:^(NSString *message) {
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    if(complete){
                        complete(jsonDict[@"messages"]);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
                if(failure){
                    failure(operation, error);
                }
            }];
        }
        
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (register device)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.responseString);
        }
        
        if(failure){
            failure(operation, error);
        }
    }];
}

@end
