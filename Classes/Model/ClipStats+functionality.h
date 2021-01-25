//
//  ClipStats+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ClipStats.h"

@interface ClipStats (functionality)

+(RKEntityMapping *)myMapping;

+(void)likeClipWithId:(NSNumber *)clipID withAccessToken:(NSString *)accessToken
                success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)unlikeClipWithId:(NSNumber *)clipID withAccessToken:(NSString *)accessToken
                success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)increaseWatchCountForClipWithId:(NSNumber *)clipID withAccessToken:(NSString *)accessToken
                               success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                               failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(ClipStats *)initWithJSONString:(NSString *)JSONString;


@end
