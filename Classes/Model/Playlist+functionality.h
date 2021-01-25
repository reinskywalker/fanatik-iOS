//
//  Playlist+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Playlist.h"

@interface Playlist (functionality)

+(RKEntityMapping *)myMapping;

+(void)getAllPlaylistWithUserId:(NSString *)userID
                  andPageNumber:(NSNumber *)pageNum
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)searchPlaylistWithQuery:(NSString *)q
                 andPageNumber:(NSNumber *)pageNum
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)createPlaylistWithDict:(NSDictionary *)dict andAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Playlist *playlist))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)addClipsWithIdArray:(NSArray *)idArray toPlaylistWithId:(NSString *)playlistID andAccessToken:(NSString *)accessToken
                   success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)deletePlaylistWithId:(NSString *)playlistID
            withAccessToken:(NSString *)accessToken
                    success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                    failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getPlaylistDetailWithUserId:(NSString *)userID
                     andPlaylistId:(NSString *)playlistID
                     andPageNumber:(NSNumber *)pageNum
                   withAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, Playlist *playlist))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)removeClipWithId:(NSNumber *)clipID
     fromPlaylistWithId:(NSString *)playlistID
        withAccessToken:(NSString *)accessToken
                success:(void(^)(RKObjectRequestOperation *operation, Playlist *playlist))success
                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
;
@end
