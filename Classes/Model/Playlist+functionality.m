//
//  Playlist+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Playlist+functionality.h"
#import "Clip.h"

typedef enum {
    PlaylistRequestTypeGetAllUserPlaylist = 0,
    PlaylistRequestTypeSearchPlaylist,
    PlaylistRequestTypeCreatePlaylist,
    PlaylistRequestTypeEditPlaylist,
    PlaylistRequestTypeAddClips,
    PlaylistRequestTypeRemoveClips,
    PlaylistRequestTypeDetail,
    PlaylistRequestTypeDestroy
}PlaylistRequestType;

@implementation Playlist (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"playlist_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"playlist_id", @"id",
                                       @"playlist_name", @"name",
                                       @"playlist_created_at", @"created_at",
                                       @"playlist_time_ago", @"time_ago",
                                       @"playlist_private", @"private",
                                       @"playlist_user_id", @"user_id",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clips" toKeyPath:@"playlist_clips" withMapping:clipMapping]];
    
    return mappingEntity;
    
}

#pragma mark - GET
+(void)getAllPlaylistWithUserId:(NSString *)userID
                  andPageNumber:(NSNumber *)pageNum
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPlaylistWithUserId:userID andPlaylistId:@""
                andQuery:nil
                andPlaylistDictionary:nil
                andClipIDArray:nil
                 withPageNumber:pageNum
                 andRequestType:PlaylistRequestTypeGetAllUserPlaylist andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

+(void)getPlaylistDetailWithUserId:(NSString *)userID
                          andPlaylistId:(NSString *)playlistID
                  andPageNumber:(NSNumber *)pageNum
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, Playlist *playlist))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPlaylistWithUserId:userID andPlaylistId:playlistID
                       andQuery:nil
          andPlaylistDictionary:nil
                 andClipIDArray:nil
                 withPageNumber:pageNum
                 andRequestType:PlaylistRequestTypeDetail andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                     if(success){
                         success(operation, [result firstObject]);
                     }
                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     if(failure){
                         failure(operation, error);
                     }
                 }];
}

+(void)searchPlaylistWithQuery:(NSString *)q
                  andPageNumber:(NSNumber *)pageNum
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPlaylistWithUserId:nil andPlaylistId:@""
                       andQuery:q
          andPlaylistDictionary:nil
                 andClipIDArray:nil
                 withPageNumber:pageNum
                 andRequestType:PlaylistRequestTypeSearchPlaylist andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

+(void)createPlaylistWithDict:(NSDictionary *)dict andAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Playlist *playlist))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    [self reqPlaylistWithUserId:nil andPlaylistId:nil andQuery:nil andPlaylistDictionary:dict andClipIDArray:nil withPageNumber:nil andRequestType:PlaylistRequestTypeCreatePlaylist andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, [result firstObject]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)deletePlaylistWithId:(NSString *)playlistID
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPlaylistWithUserId:nil andPlaylistId:playlistID
                       andQuery:nil
          andPlaylistDictionary:nil
                 andClipIDArray:nil
                 withPageNumber:nil
                 andRequestType:PlaylistRequestTypeDestroy andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

+(void)removeClipWithId:(NSNumber *)clipID
                     fromPlaylistWithId:(NSString *)playlistID
                   withAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, Playlist *playlist))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPlaylistWithUserId:nil andPlaylistId:playlistID
                       andQuery:nil
          andPlaylistDictionary:nil
                 andClipIDArray:@[clipID]
                 withPageNumber:nil
                 andRequestType:PlaylistRequestTypeRemoveClips andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                     if(success){
                         success(operation, [result firstObject]);
                     }
                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     if(failure){
                         failure(operation, error);
                     }
                 }];
}

#pragma mark - POST

+(void)addClipsWithIdArray:(NSArray *)idArray toPlaylistWithId:(NSString *)playlistID andAccessToken:(NSString *)accessToken
           success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    [self reqPlaylistWithUserId:nil andPlaylistId:playlistID andQuery:nil andPlaylistDictionary:nil andClipIDArray:idArray withPageNumber:nil andRequestType:PlaylistRequestTypeAddClips andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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
+ (void)reqPlaylistWithUserId:(NSString*)userID andPlaylistId:(NSString *)playlistID
                     andQuery:(NSString *)q
        andPlaylistDictionary:(NSDictionary *)dict
               andClipIDArray:(NSArray *)idArray
               withPageNumber:(NSNumber *)pageNum
           andRequestType:(PlaylistRequestType)reqType
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
        case PlaylistRequestTypeGetAllUserPlaylist:{
            pathPattern = [NSString stringWithFormat:@"users/%@/playlists",userID];
            keyPath = @"playlists";
        }
            break;
        case PlaylistRequestTypeSearchPlaylist:{
            pathPattern = @"playlists/search";
            keyPath = @"playlists";
            params[@"q"] = q;
        }
            break;
        case PlaylistRequestTypeCreatePlaylist:{
            pathPattern = @"playlists";
            params[@"playlist"] = dict;
            requestMethod = RKRequestMethodPOST;
        }
            break;
        case PlaylistRequestTypeEditPlaylist:{
            pathPattern = [NSString stringWithFormat:@"playlists/%@",playlistID];
            params[@"playlist"] = dict;
            requestMethod = RKRequestMethodPATCH;
        }
            break;
        case PlaylistRequestTypeAddClips:{
            pathPattern = [NSString stringWithFormat:@"playlists/%@/add",playlistID];
            params[@"clip_id"] = idArray[0];
            requestMethod = RKRequestMethodPATCH;
        }
            break;
        case PlaylistRequestTypeRemoveClips:{
            pathPattern = [NSString stringWithFormat:@"playlists/%@/remove",playlistID];
            params[@"clip_id"] = idArray[0];
            requestMethod = RKRequestMethodDELETE;
        }
            break;
        case PlaylistRequestTypeDetail:{
            pathPattern = [NSString stringWithFormat:@"users/%@/playlists/%@",userID,playlistID];
        }
            break;
        case PlaylistRequestTypeDestroy:{
            pathPattern = [NSString stringWithFormat:@"playlists/%@",playlistID];
            requestMethod = RKRequestMethodDELETE;
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

                [self reqPlaylistWithUserId:userID andPlaylistId:playlistID andQuery:q
                      andPlaylistDictionary:dict andClipIDArray:idArray withPageNumber:pageNum andRequestType:reqType andAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                          if(success){
                              success(operation, result);
                          }
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
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
