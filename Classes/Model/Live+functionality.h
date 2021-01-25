//
//  Live+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Live.h"

@interface Live (functionality)

+(RKEntityMapping *)baseMapping;
+(RKEntityMapping *)myMapping;

+(void)getAllLivewithAccessToken:(NSString *)accessToken
                        andPageNumber:(NSNumber *)page
                         success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getLiveWithLiveId:(NSString *)liveID
        andPageNumber:(NSNumber *)page
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, Live *object))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;


@end
