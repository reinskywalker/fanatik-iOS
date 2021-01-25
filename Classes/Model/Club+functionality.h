//
//  Club+functionality.h
//
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Club.h"

@interface Club (functionality)

+(RKEntityMapping *)myMapping;

+(void)getClubListWithAccessToken:(NSString *)accessToken
                       pageNumber:(NSNumber *)pageNum
                          success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(void)getMyClubWithAccessToken:(NSString *)accessToken
                     pageNumber:(NSNumber *)pageNum
                        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(void)getClubWithClubId:(NSString *)clubId withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, Club *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)searchClubWithSearchString:(NSString *)searchStr
                    andPageNumber:(NSNumber *)pageNum
                  withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)joinClubWithID:(NSString *)clubID andAccessToken:(NSString *)accessToken
        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)leaveClubWithID:(NSString *)clubID withAccessToken:(NSString *)accessToken
         success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
